//
//  DrawerPresentationController.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/9/14.
//

import UIKit
import Combine


protocol DrawerPresentationControllerDelegate: AnyObject {
    /// Called when the user requests the dismissal of the presentingViewController
    func drawerPresentationControllerDismissalRequested(_ presentationController: DrawerPresentationController)
    
    func drawerPrsentationControllerPresentedViewMaskUpdateRequested(_ presentationController: DrawerPresentationController, expectedMaskedCorners: CACornerMask)
}


class DrawerPresentationController: UIPresentationController {
    private struct Constants {
        static let minHorizontalMargin: CGFloat = 44
        static let minVerticalMargin: CGFloat = .XUI.spacing5
    }

    let sourceViewController: UIViewController
    let presentationDirection: Direction
    let preferredMaximumExpansionHeight: CGFloat
    let presentationOrigin: CGFloat?
    let presentationOffset: CGFloat
    let shouldUseWindowFullWidthInLandscape: Bool
    let shouldRespectSafeAreaForWindowFullWidth: Bool

    weak var drawerPresentationControllerDelegate: DrawerPresentationControllerDelegate?
    
    private var keyboardManager: KeyboardManager?
    
    private var cancellable: AnyCancellable?

    init(presentedViewController: UIViewController,
         presentingViewController: UIViewController?,
         sourceViewController: UIViewController,
         presentationDirection: Direction,
         preferredMaximumExpansionHeight: CGFloat,
         presentationOrigin: CGFloat?,
         presentationOffset: CGFloat,
         shouldUseWindowFullWidthInLandscape: Bool,
         shouldRespectSafeAreaForWindowFullWidth: Bool,
         adjustHeightForKeyboard: Bool) {
        self.sourceViewController = sourceViewController
        self.presentationDirection = presentationDirection
        self.preferredMaximumExpansionHeight = preferredMaximumExpansionHeight
        self.presentationOrigin = presentationOrigin
        self.presentationOffset = presentationOffset
        self.shouldUseWindowFullWidthInLandscape = shouldUseWindowFullWidthInLandscape
        self.shouldRespectSafeAreaForWindowFullWidth = shouldRespectSafeAreaForWindowFullWidth

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        if adjustHeightForKeyboard {
            keyboardManager = KeyboardManager()
            cancellable = keyboardManager?.didReceiveEventPublisher
                .filter { $0.0 == .willChangeFrame }
                .sink { [weak self] (_, info) in
                    self?.keyboardWillChangeFrame(info)
                }
        }
    }
    
    private lazy var dismissalInteractiveView: UIView = {
        let view = UIView()
        view.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(handleDismissalInteractiveViewTapped(_:)))]
        return view
    }()

    private lazy var dimmingView = BackgroundView(configuration: .dimmingBlack())
    
    // `contentView` contains content in majority of cases with 2 exceptions: after horizontal presentations and in non-animated presentations. `containerView` contains everything directly or indirectly, in some cases (2 cases described above) it will also contain content (but use `contentView` for layout information).
    private lazy var contentView = UIView()
  
    // Imitates the bottom shadow of navigation bar or top shadow of toolbar because original ones are hidden by presented view
    private lazy var separator = SeparatorView(color: Colors.shadow)

    // MARK: Presentation
    
    // Prevent animating content view frame during presentation.
    private var enablesContentViewFrameUpdate = false

    override func presentationTransitionWillBegin() {
        if let containerView = containerView {
            containerView.addSubview(dismissalInteractiveView)
            dismissalInteractiveView.fitIntoSuperview()
            dismissalInteractiveView.addSubview(dimmingView)
            
            containerView.addSubview(contentView)
            // Clipping is added to prevent any animation bug sliding over the navigation bar
            contentView.clipsToBounds = true
      
            if presentationDirection.isVertical && actualPresentationOffset == 0 {
                containerView.addSubview(separator)
            }
        }
        updateLayout()
        
        // In non-animated presentations presented view will be force-placed into containerView by UIKit
        // For animated presentations presented view must be inside contentView to not slide over navigation bar/toolbar
        if presentingViewController.transitionCoordinator?.isAnimated == true {
            // Avoiding content animation due to showing of the keyboard (when presented view contains the first responder)
            presentedViewController.view.frame = frameForPresentedViewController(in: contentView.bounds)
            presentedViewController.view.layoutIfNeeded()

            contentView.addSubview(presentedViewController.view)
        }

        setPresentedViewMask()
        
        dimmingView.alpha = 0.0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
        
        enablesContentViewFrameUpdate = true
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed {
            // Horizontally presented drawers must be inside containerView in order for device rotation animation to work correctly
            if presentationDirection.isHorizontal {
                containerView?.addSubview(presentedViewController.view)
                presentedViewController.view.frame = frameForPresentedViewController(in: contentView.bounds)
            }
        } else {
            separator.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        // For animated presentations presented view must be inside contentView to not slide over navigation bar/toolbar
        if let transitionCoordinator = presentingViewController.transitionCoordinator, transitionCoordinator.isAnimated == true {
            contentView.addSubview(presentedViewController.view)
            presentedViewController.view.frame = frameForPresentedViewController(in: contentView.bounds)

            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0.0
            })
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            separator.removeFromSuperview()
        }
    }

    // MARK: Layout

    enum ExtraContentSizeEffect {
        case move
        case resize
    }

    override var frameOfPresentedViewInContainerView: CGRect { return contentView.frame }

    var extraContentSizeEffectWhenCollapsing: ExtraContentSizeEffect = .move

    private var actualPresentationOffset: CGFloat {
        if presentationDirection.isVertical && traitCollection.horizontalSizeClass == .regular {
            return max(0, presentationOffset)
        }
        return 0
    }
    
    private var actualPresentationOrigin: CGFloat {
        if let presentationOrigin = presentationOrigin {
            return presentationOrigin
        }

        let containerBounds = containerView?.bounds ?? UIScreen.main.bounds
        switch presentationDirection {
        case .down:
            var controller = sourceViewController
            while let navigationController = controller.navigationController {
                let navigationBar = navigationController.navigationBar
                if !navigationBar.isHidden, let navigationBarParent = navigationBar.superview {
                    return navigationBarParent.convert(navigationBar.frame, to: containerView).maxY
                }
                controller = navigationController
            }
            return containerBounds.minY
        case .up:
            return containerBounds.maxY
        case .fromLeading:
            return containerBounds.minX
        case .fromTrailing:
            return containerBounds.maxX
        }
    }
    private var extraContentSize: CGFloat = 0
    private var safeAreaPresentationOffset: CGFloat {
        guard let containerView = containerView else {
            return 0
        }
        switch presentationDirection {
        case .down:
            if actualPresentationOrigin == containerView.bounds.minY {
                return containerView.safeAreaInsets.top
            }
        case .up:
            if actualPresentationOrigin == containerView.bounds.maxY {
                return containerView.safeAreaInsets.bottom + keyboardHeight
            }
        case .fromLeading:
            if actualPresentationOrigin == containerView.bounds.minX {
                return containerView.safeAreaInsets.left
            }
        case .fromTrailing:
            if actualPresentationOrigin == containerView.bounds.maxX {
                return containerView.safeAreaInsets.right
            }
        }
        return 0
    }
    private var keyboardHeight: CGFloat = 0 {
        didSet {
            if keyboardHeight != oldValue {
                updateContentViewFrame(animated: true, animationDuration: keyboardAnimationDuration)
                separator.isHidden = keyboardHeight != 0
            }
        }
    }
    private var keyboardAnimationDuration: Double?

    private var isUpdatingContentViewFrame: Bool = false

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        updateLayout()
        // In non-animated presentations presented view will be force-placed into containerView by UIKit after separator thus hiding it
        containerView?.bringSubviewToFront(separator)
    }

    func setExtraContentSize(_ extraContentSize: CGFloat, updatingLayout updateLayout: Bool = true, animated: Bool = false) {
        if self.extraContentSize == extraContentSize {
            return
        }
        self.extraContentSize = extraContentSize
        if updateLayout {
            updateContentViewFrame(animated: animated)
        }
    }

    func updateContentViewFrame(animated: Bool, animationDuration: TimeInterval? = nil) {
        if !enablesContentViewFrameUpdate {
            return
        }
        
        if isUpdatingContentViewFrame {
            return
        }
        isUpdatingContentViewFrame = true

        let newFrame = frameForContentView()
        if animated {
            let sizeChange = presentationDirection.isVertical ? newFrame.height - contentView.frame.height : newFrame.width - contentView.frame.width
            let animationDuration = animationDuration ?? DrawerTransitionAnimator.animationDuration(forSizeChange: sizeChange)
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.layoutSubviews], animations: {
                self.setContentViewFrame(newFrame)
                self.isUpdatingContentViewFrame = false
            })
        } else {
            setContentViewFrame(newFrame)
            isUpdatingContentViewFrame = false
        }
    }

    private func setContentViewFrame(_ frame: CGRect) {
        contentView.frame = frame

        if let presentedView = presentedView {
            let presentedViewFrame = frameForPresentedViewController(in: presentedView.superview == containerView ? contentView.frame : contentView.bounds)

            // On iOS 13 and iOS 14 the safeAreaInsets are not applied when the presentedView is not entirely within the screen bounds.
            // As a workaround, additional safe area insets need to be set to compensate.
            if #available(iOS 15.0, *) {} else {
                let isVerticallyPresentedViewPartiallyOffScreen: Bool = {
                    // Calculates the origin of the presentedView frame in relation to the device screen.
                    guard let origin = presentedView.superview?.convert(presentedViewFrame.origin, to: nil) else {
                        return false
                    }

                    return (presentationDirection == .down && origin.y < 0) ||
                           (presentationDirection == .up && (origin.y + presentedViewFrame.height - UIScreen.main.bounds.height) > 0)
                }()

                presentedViewController.additionalSafeAreaInsets = isVerticallyPresentedViewPartiallyOffScreen ? contentView.safeAreaInsets : .zero
            }

            presentedView.frame = presentedViewFrame
        }

        if separator.superview != nil {
            separator.frame = frameForSeparator(in: contentView.frame, withThickness: separator.frame.height)
        }
    }

    private func updateLayout() {
        dimmingView.frame = frameForDimmingView(in: dismissalInteractiveView.bounds)
        setContentViewFrame(frameForContentView())
    }
    
    private func frameForDimmingView(in bounds: CGRect) -> CGRect {
        var margins: UIEdgeInsets = .zero
        switch presentationDirection {
        case .down:
            margins.top = actualPresentationOrigin
        case .up:
            margins.bottom = bounds.height - actualPresentationOrigin
        case .fromLeading:
            margins.left = actualPresentationOrigin
        case .fromTrailing:
            margins.right = bounds.width - actualPresentationOrigin
        }
        return bounds.inset(by: margins)
    }


    private func frameForContentView() -> CGRect {
        // Positioning content view relative to dimming view
        return frameForContentView(in: dimmingView.frame)
    }

    private func frameForContentView(in bounds: CGRect) -> CGRect {
        var contentFrame = bounds.inset(by: marginsForContentView())

        var contentSize = presentedViewController.preferredContentSize

        let landscapeMode: Bool
        if let windowSize = sourceViewController.view.window?.frame.size {
            landscapeMode = windowSize.width > windowSize.height
        } else {
            landscapeMode = false
        }

        if presentationDirection.isVertical {
            if contentSize.width == 0 ||
                (traitCollection.userInterfaceIdiom == .phone && landscapeMode && shouldUseWindowFullWidthInLandscape) ||
                (traitCollection.horizontalSizeClass == .compact && !landscapeMode) {
                contentSize.width = contentFrame.width
            }

            if actualPresentationOffset == 0 && (presentationDirection == .down || keyboardHeight == 0) {
                contentSize.height += safeAreaPresentationOffset
            }

            contentSize.height = min(contentSize.height, contentFrame.height)
            if extraContentSize >= 0 || extraContentSizeEffectWhenCollapsing == .resize {
                let maxContentSize = preferredMaximumExpansionHeight != -1 ? preferredMaximumExpansionHeight : contentFrame.height
                contentSize.height = min(contentSize.height + extraContentSize, maxContentSize)
            }

            contentFrame.origin.x += (contentFrame.width - contentSize.width) / 2
            if presentationDirection == .up {
                contentFrame.origin.y = contentFrame.maxY - contentSize.height
            }
        } else {
            if actualPresentationOffset == 0 {
                contentSize.width += safeAreaPresentationOffset
            }
            contentSize.width = min(contentSize.width, contentFrame.width)
            contentSize.height = contentFrame.height

            if presentationDirection == .fromTrailing {
                contentFrame.origin.x = contentFrame.maxX - contentSize.width
            }
        }
        contentFrame.size = contentSize

        return contentFrame
    }

    private func marginsForContentView() -> UIEdgeInsets {
        guard let containerView = containerView else {
            return .zero
        }

        let presentationOffsetMargin = actualPresentationOffset > 0 ? safeAreaPresentationOffset + actualPresentationOffset : 0
        var margins: UIEdgeInsets = .zero

        if presentationDirection.isVertical && shouldRespectSafeAreaForWindowFullWidth {
            margins.left = containerView.safeAreaInsets.left
            margins.right = containerView.safeAreaInsets.right
        }

        switch presentationDirection {
        case .down:
            margins.top = presentationOffsetMargin
            margins.bottom = max(Constants.minVerticalMargin, containerView.safeAreaInsets.bottom)
        case .up:
            margins.top = max(Constants.minVerticalMargin, containerView.safeAreaInsets.top)
            margins.bottom = presentationOffsetMargin
            if actualPresentationOffset == 0 && keyboardHeight > 0 {
                margins.bottom += safeAreaPresentationOffset
            }
        case .fromLeading:
            margins.left = presentationOffsetMargin
            margins.right = max(Constants.minHorizontalMargin, containerView.safeAreaInsets.right)
        case .fromTrailing:
            margins.left = max(Constants.minHorizontalMargin, containerView.safeAreaInsets.left)
            margins.right = presentationOffsetMargin
        }
        return margins
    }

    private func frameForPresentedViewController(in bounds: CGRect) -> CGRect {
        var frame = bounds

        // Moves the presented view controller (drawer) towards its presenting base in the content view if it's being dragged to dismissal.
        // In case the drawer is being expanded, the content view grows with the gesture extra content size and the drawer keeps its
        // original offset relative to the content view.
        let gestureOffset = extraContentSize < 0 && extraContentSizeEffectWhenCollapsing == .move ? extraContentSize : 0

        if presentationDirection.isVertical {
            frame.origin.y += presentationDirection == .down ? gestureOffset : -gestureOffset
        } else {
            frame.origin.x += presentationDirection == .fromLeading ? gestureOffset : -gestureOffset
        }

        return frame
    }

    private func frameForSeparator(in bounds: CGRect, withThickness thickness: CGFloat) -> CGRect {
        return CGRect(
            x: bounds.minX,
            y: presentationDirection == .down ? bounds.minY : bounds.maxY - thickness,
            width: bounds.width,
            height: thickness
        )
    }
    
    private func keyboardWillChangeFrame(_ info: KeyboardInfo) {
        guard let containerView = containerView else {
            return
        }

        if info.isLocal == false {
            return
        }

        guard var _ = info.endFrame else {
            return
        }
        
        keyboardAnimationDuration = info.animationDuration
        keyboardHeight = max(0, KeyboardManager.distanceFromMinYToBottom(of: containerView, keyboardRect: info.endFrame, respectsSafeArea: true))
    }
    

    // MARK: Presented View Mask
    
    private func setPresentedViewMask() {
        let maskedCorners: CACornerMask
        if actualPresentationOffset == 0 {
            switch presentationDirection {
            case .down:
                maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .up:
                maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case .fromLeading, .fromTrailing:
                maskedCorners = []
            }
        } else {
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

        drawerPresentationControllerDelegate?.drawerPrsentationControllerPresentedViewMaskUpdateRequested(self, expectedMaskedCorners: maskedCorners)
    }

    // MARK: Actions

    @objc private func handleDismissalInteractiveViewTapped(_ recognizer: UITapGestureRecognizer) {
        drawerPresentationControllerDelegate?.drawerPresentationControllerDismissalRequested(self)
    }
}
