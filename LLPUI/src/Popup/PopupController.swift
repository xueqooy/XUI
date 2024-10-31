//
//  PopupController.swift
//  LLPUI
//
//  Created by xueqooy on 2023/2/28.
//

import UIKit
import SnapKit


/// `PopupController` is used to present a portion of UI  in the center of the screen
open class PopupController: UIViewController, Configurable {
        
    public enum ContentHorizontalSizeClass {
        case regular, compact
    }
    
    public struct Configuration: Equatable {
        
        public var title: String? = nil
        
        public var showsCancelButton: Bool = true
        
        /**
         Indicate the default width size class of the content when `preferredContentSize.width <= 0` and there is sufficient available layout width
         */
        public var contentHorizontalSizeClass: ContentHorizontalSizeClass
                
        /**
         Set `adjustsHeightForKeyboard` to `true` to allow popup to adjust its height when keyboard is shown or hidden, so that popup's content is always visible.
         */
        public var adjustsHeightForKeyboard: Bool = true

        public var wrapsContentWithDefaultInsets: Bool = true
        
        public init(title: String? = nil, showsCancelButton: Bool = true, adjustsHeightForKeyboard: Bool = true, wrapsContentWithDefaultInsets: Bool = true, contentHorizontalSizeClass: ContentHorizontalSizeClass = .compact) {
            self.title = title
            self.showsCancelButton = showsCancelButton
            self.adjustsHeightForKeyboard = adjustsHeightForKeyboard
            self.wrapsContentWithDefaultInsets = wrapsContentWithDefaultInsets
            self.contentHorizontalSizeClass = contentHorizontalSizeClass
        }
        
    }
    
    public var configuration: Configuration {
        didSet {
            guard configuration != oldValue else {
                return
            }
            
            if oldValue.title != configuration.title || oldValue.showsCancelButton != configuration.showsCancelButton {
                updateTopView()
            }

            if oldValue.adjustsHeightForKeyboard != configuration.adjustsHeightForKeyboard {
                (presentationController as? PopupPresentationController)?.adjustHeightForKeyboard = configuration.adjustsHeightForKeyboard
            }
            
            if oldValue.wrapsContentWithDefaultInsets != configuration.wrapsContentWithDefaultInsets {
                if let currentContentController = contentController {
                    contentController = nil
                    contentController = currentContentController
                } else if let currentContentView = _contentView {
                    contentView = nil
                    contentView = currentContentView
                }
            }
            
            updateLayout()
        }
    }
    
    /**
     Set `contentController` to provide a controller that will represent popup's content. Its view will be hosted in the root view of the popoup and will be sized and positioned to accommodate any shell UI of the popup.

     Content controller can provide `preferredContentSize` which will be used as a content size to calculate the size of the popup on screen.
     */
    open var contentController: UIViewController? {
        didSet {
            if contentController == oldValue {
                return
            }
            if _contentView != nil {
                preconditionFailure("PopupController: contentController cannot be set while contentView is assigned")
            }

            if let oldContentController = oldValue {
                oldContentController.willMove(toParent: nil)
                oldContentController.view.removeFromSuperview()
                oldContentController.removeFromParent()

            }
            if let contentController = contentController {
                addChild(contentController)
                
                let view: UIView
                if configuration.wrapsContentWithDefaultInsets {
                    wrapContentView(contentController.view)
                    view = contentWrapperView
                } else {
                    view = contentController.view
                }
                containerView.addArrangedSubview(view)
                
                contentController.didMove(toParent: self)
            }
        }
    }
    
    private var _contentView: UIView?
    /**
     Set `contentView` to provide a view that will represent popup's content. It will be hosted in the root view of the popup and will be sized and positioned to accommodate any shell UI of the drawer.

     If you want to specify the size of the content inside the drawer then you can do this through popup's `preferredContentSize` which will be used to calculate the size of the popup on screen. Otherwise the fitting size of the content view will be used.
     */
    open var contentView: UIView? {
        get {
            return contentController?.view ?? _contentView
        }
        set {
            if contentView == newValue {
                return
            }
            if contentController != nil {
                preconditionFailure("PopupController: contentView cannot be set while contentController is assigned")
            }

            _contentView?.removeFromSuperview()
            _contentView = newValue
            if let contentView = _contentView {
                let view: UIView
                if configuration.wrapsContentWithDefaultInsets {
                    wrapContentView(contentView)
                    view = contentWrapperView
                } else {
                    view = contentView
                }
                containerView.addArrangedSubview(view)
            }
        }
    }
    
    open override var preferredContentSize: CGSize {
        get {
            // Content size priority order:
            // popupController.preferredContentSize > contentController.preferredContentSize > contentView.systemLayoutSizeFitting
            
            var preferredContentSize = CGSize.zero
            
            let updatePreferredContentSize = { (getWidth: @autoclosure () -> CGFloat, getHeight: @autoclosure () -> CGFloat) in
                if preferredContentSize.width <= 0 {
                    preferredContentSize.width = getWidth()
                }
                if preferredContentSize.height <= 0 {
                    preferredContentSize.height = getHeight()
                    if preferredContentSize.height > 0, let topView = self.topView {
                        preferredContentSize.height += topView.intrinsicContentSize.height
                    }
                }
            }
            
            updatePreferredContentSize(super.preferredContentSize.width, super.preferredContentSize.height)
            
            if let contentController = contentController {
                var contentSize = contentController.preferredContentSize
                
                if configuration.wrapsContentWithDefaultInsets {
                    if contentSize.width > 0 {
                        contentSize.width += contentWrapperView.layoutMargins.horizontal
                    }
                    
                    if contentSize.height > 0 {
                        contentSize.height +=  contentWrapperView.layoutMargins.vertical
                    }
                }
                
                updatePreferredContentSize(contentSize.width, contentSize.height)
            }
            
            if let contentView = contentView {
                var contentSize = preferredContentSize
                if contentSize.width <= 0 {
                    contentSize.width = calculateSuggestedContentWidth()
                }
                
                if contentSize.height <= 0 {
                    let theView = (configuration.wrapsContentWithDefaultInsets ? contentWrapperView : contentView)
                    if contentSize.width <= 0 {
                        contentSize = theView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                    } else {
                        contentSize.height = theView.systemLayoutSizeFitting(CGSize(width: contentSize.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
                    }
                }
                
                updatePreferredContentSize(contentSize.width, contentSize.height)
            }
            return CGSize(width: preferredContentSize.width.flatInPixel(), height: preferredContentSize.height.flatInPixel())
        }
        set {
            super.preferredContentSize = newValue
            updateLayout()
        }
    }
        
    private let backgroundView: BackgroundView = {
        let view = BackgroundView(configuration: .overlay())
        return view
    }()
    
    private lazy var containerView: VStackView = {
        let stackView = VStackView()
        
        stackView.layer.cornerRadius = .LLPUI.cornerRadius
        stackView.layer.masksToBounds = true
        
        return stackView
    }()
    
    private var topView: PopupTopView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let topView = topView {
                containerView.insertArrangedSubview(topView, at: 0)
            }
        }
    }
    
    private lazy var contentWrapperView = UIView()
        
    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
    
        super.init(nibName: nil, bundle: nil)
                    
        initialize()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func initialize() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
                
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        updateTopView()
        maybeUpdateMarginsForContentWrapper()
    }

    public func updateLayout(animated: Bool = true) {
        contentView?.invalidateIntrinsicContentSize()
        (presentationController as? PopupPresentationController)?.updateLayout(animated: animated)
    }
    
    private func maybeUpdateMarginsForContentWrapper() {
        if !configuration.wrapsContentWithDefaultInsets {
            return
        }
                
        let reduceTopInset: Bool
        if let _ = topView {
            reduceTopInset = (configuration.title ?? "").isEmpty
        } else {
            reduceTopInset = false
        }
        
        var layoutMargins = UIEdgeInsets(top: .LLPUI.spacing5, left: .LLPUI.spacing5, bottom: .LLPUI.spacing5, right: .LLPUI.spacing5)
        if reduceTopInset {
            layoutMargins.top = .LLPUI.spacing2
        }

        contentWrapperView.layoutMargins = layoutMargins
    }
    
    private func wrapContentView(_ contentView: UIView) {
        contentWrapperView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.equalTo(contentWrapperView.snp.leadingMargin)
            make.trailing.equalTo(contentWrapperView.snp.trailingMargin)
            make.top.equalTo(contentWrapperView.snp.topMargin)
            make.bottom.equalTo(contentWrapperView.snp.bottomMargin)
        }
    }
    
    private func updateTopView() {
        topView = PopupTopView(title: configuration.title, cancelAction: configuration.showsCancelButton ? { [weak self] in
            self?.dismiss(animated: true)
        } : nil)
    }
    
    private func calculateSuggestedContentWidth() -> CGFloat {
        var suggestedWidth = 0.0
        let windowWidth = (self.view.window ?? self.view)?.frame.width ?? 0
        
        let useFullWidth: Bool
        if traitCollection.userInterfaceIdiom == .phone {
            if Device.current.orientation == .landscape {
                useFullWidth = false
            } else {
                useFullWidth = true
            }
        } else if traitCollection.horizontalSizeClass == .compact {
            useFullWidth = true
        } else {
            useFullWidth = false
        }

        if useFullWidth {
            suggestedWidth -= (self.view.safeAreaInsets.horizontal + 2 * CGFloat.LLPUI.spacing6)
        } else {
            let scale = switch configuration.contentHorizontalSizeClass {
            case .regular:
                0.7
                
            case .compact:
                0.5
            }
            suggestedWidth = max(375, windowWidth * scale)
        }
        
        return ceil(suggestedWidth)
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        updateLayout()
    }
}

extension PopupController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        PopupTransitionAnimator(isPresenting: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        PopupTransitionAnimator(isPresenting: false)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PopupPresentationController(presentedViewController: presented, presentingViewController: presenting, adjustHeightForKeyboard: configuration.adjustsHeightForKeyboard)
    }
}
