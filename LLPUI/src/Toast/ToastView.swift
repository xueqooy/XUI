//
//  ToastView.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/9/20.
//

import UIKit
import LLPUtils

/// A toast with success, error, info and wanring style
///
/// Note: If you wanna show notificaiton view with a auto-hide
/// the right way is:
/// ```
/// toastView.show(from: viewController) { view in
///     view.hide(after: .autoHideDelay)
/// }
/// ```
///  but NOT:
/// ```
/// toastView.show(from: viewController)
/// toastView.hide(after: .LLPUI.autoHideDelay)
/// ```
///
/// ```
/// In concurrency context:
///
/// await toastView.show(from: viewController, animated: true)
/// await toastView.hide(after: .LLPUI.autoHideDelay)
///
/// ```
///
///
/// The second way may result in the view not being hide automatically when already exists a notification view.
/// 

public class ToastView: UIView, Configurable {
    
    private struct Constants {
        static let horizontalSpacing: CGFloat = .LLPUI.spacing4
        static let verticalSpacing: CGFloat = .LLPUI.spacing1

        static let contentInset = UIEdgeInsets(top: .LLPUI.spacing2, left: .LLPUI.spacing4, bottom: .LLPUI.spacing2, right: .LLPUI.spacing4)
        static let contentInsetWhenDisplayingActionButton = UIEdgeInsets(top: .LLPUI.spacing2, left: .LLPUI.spacing4, bottom: .LLPUI.spacing4, right: .LLPUI.spacing4)
        static let presentationOffset: CGFloat = 20
        
        static let animationDurationForShow: TimeInterval = 0.4
        static let animationDurationForHide: TimeInterval = 0.2
        static let animationDampingRatio: CGFloat = 0.5
    }
    
    public enum Style {
        case success
        case error
        case info
        case warning
        case reminder
        
        var backgroundColor: UIColor {
            switch self {
            case .success:
                return Colors.title
            case .error:
                return Colors.lightRed
            case .info:
                return Colors.blue
            case .warning:
                return Colors.yellowOrange
            case .reminder:
                return Colors.lightTeal
            }
        }
        
        var foregroundColor: UIColor {
            switch self {
            case .reminder:
                return Colors.title
            default:
                return .white
            }
        }
        
        var cornerRadius: CGFloat {
            .LLPUI.smallCornerRadius
        }
        
        var image: UIImage {
            switch self {
            case .success:
                return Icons.toastSuccess
            case .error:
                return Icons.toastError
            case .info:
                return Icons.toastInfo
            case .warning:
                return Icons.toastWarning
            case .reminder:
                return Icons.toastReminder
            }
        }
        
        var hapticFeedbackType: HapticFeedbackType? {
            switch self {
            case .success:
                return .success
            case .error:
                return .error
            case .info:
                return nil
            case .warning:
                return .warning
            case .reminder:
                return nil
            }
        }
    }
    
    public struct Configuration: Equatable, Then {

        public struct Action: Equatable {

            public let title: String
            public let handler: () -> Void
            
            private let identifier: UUID = .init()
            
            public init(title: String, handler: @escaping () -> Void) {
                self.title = title
                self.handler = handler
            }
            
            public static func == (lhs: Configuration.Action, rhs: Configuration.Action) -> Bool {
                lhs.identifier == rhs.identifier
            }
        }
        
        public var style: Style
        public var message: String
        public var richMessage: RichText?
        public var action: Action?
        
        public var isEmptyMessage: Bool {
            if let richMessage = richMessage {
                return richMessage.length == 0
            } else {
                return message.isEmpty
            }
        }
        
        public init(style: Style = .success, message: String = "", richMessage: RichText? = nil, action: Action? = nil) {
            self.style = style
            self.message = message
            self.richMessage = richMessage
            self.action = action
        }
    }
    
    public static var allowsMultipleToasts: Bool = false

    private static var currentToast: ToastView? {
        didSet {
            if allowsMultipleToasts {
                currentToast = nil
            }
        }
    }

    public private(set) var isShown: Bool = false

    public var configuration: Configuration {
        didSet {
            update()
        }
    }
        
    private var isHiding: Bool = false
    private var completionsForHide: [() -> Void] = []
    
    private var autoHideTimer: LLPUtils.Timer?
    
    private let backgroundView = BackgroundView()
    
    private let VContainer = VStackView(spacing: .LLPUI.spacing2, layoutMargins: Constants.contentInset)
    
    private let HContainer = HStackView(distribution: .fill, alignment: .center, spacing: Constants.horizontalSpacing)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let messageLabel = UILabel()
        if #available(iOS 14, *) {
            messageLabel.lineBreakStrategy = []
        }
        messageLabel.font = Fonts.body2
        messageLabel.numberOfLines = 0
        messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        messageLabel.setContentHuggingPriority(.required, for: .vertical)
        return messageLabel
    }()
    
    private lazy var actionButton = Button(designStyle: .secondarySmall, alternativeBackgroundColor: .white)
    
    private lazy var actionContainerView = AlignedContainerView(actionButton, alignment: .centerHorizontally)
   
    private var constraintWhenHidden: NSLayoutConstraint!
    private var constraintWhenShown: NSLayoutConstraint!
            
    private var hapticFeedback: HapticFeedback?
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        recognizer.delegate = self
        return recognizer
    }()
    private lazy var swipeGestureRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        recognizer.direction = .down
        return recognizer
    }()
            
    private var effectiveContentInset: UIEdgeInsets {
        shouldShowActionButton ? Constants.contentInsetWhenDisplayingActionButton : Constants.contentInset
    }
    
    private var shouldShowActionButton: Bool {
        configuration.action != nil && !configuration.action!.title.isEmpty
    }
    
    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        
        super.init(frame: .zero)
        
        initialize()
    }
    
    public convenience init(style: Style = .success, message: String = "", richMessage: RichText? = nil) {
        self.init(configuration: .init(style: style, message: message, richMessage: richMessage))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()

        isShown = false
        if ToastView.currentToast == self {
            ToastView.currentToast = nil
        }
    }
    
    public override var canBecomeFirstResponder: Bool {
        true
    }

    public func initialize() {
        addSubview(backgroundView)
        addSubview(VContainer)

        HContainer.addArrangedSubview(imageView)
        HContainer.addArrangedSubview(messageLabel)
        
        VContainer.addArrangedSubview(HContainer)
        VContainer.addArrangedSubview(actionContainerView)

        backgroundView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        VContainer.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
        }

        update()

        actionButton.touchUpInsideAction = { [weak self] _ in
            guard let self, let action = self.configuration.action else { return }
            
            action.handler()
        }
    }
    
    public func triggerFeedback() {
        hapticFeedback?.trigger()
    }
    
    /// `show` is used to present the view inside a container view: insert into layout and show with optional animation. Constraints are used for the view positioning.
    /// - Parameters:
    ///   - view: The container view where this view will be presented.
    ///   - anchorView: The view used as the bottom anchor for presentation (notification view is always presented up from the anchor). When no anchor view is provided the bottom anchor of the container's safe area is used.
    ///   - animated: Indicates whether to use animation during presentation or not.
    ///   - completion: The closure to be called after presentation is completed. Can be used to call `hide` with a delay.
    public func show(in view: UIView, from anchorView: UIView? = nil, animated: Bool = true, completion: ((ToastView) -> Void)? = nil) {
        self.autoHideTimer = nil
        
        if isShown {
            completion?(self)
            return
        }

        if let currentToast = ToastView.currentToast {
            currentToast.hide(animated: animated) {
                self.show(in: view, from: anchorView, animated: animated, completion: completion)
            }
            return
        }
        
        setupHapticFeedback()
        setupGestureRecognizers()

        translatesAutoresizingMaskIntoConstraints = false
        if let anchorView = anchorView, anchorView.superview == view {
            view.insertSubview(self, belowSubview: anchorView)
        } else {
            view.addSubview(self)
        }
        
        var anchor: NSLayoutAnchor<NSLayoutYAxisAnchor>
        
        if let anchorView = anchorView {
            anchor = anchorView.topAnchor
        } else {
            anchor = view.dockedKeyboardLayoutGuide.topAnchor
        }
      
        constraintWhenHidden = topAnchor.constraint(equalTo: anchor)
        constraintWhenShown = bottomAnchor.constraint(equalTo: anchor, constant: -Constants.presentationOffset)

        var constraints = [NSLayoutConstraint]()
        constraints.append(animated ? constraintWhenHidden : constraintWhenShown)
        constraints.append(centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor, constant: -2 * Constants.presentationOffset))
        NSLayoutConstraint.activate(constraints)

        isShown = true
        ToastView.currentToast = self
        
        triggerFeedback()

        let completionForShow = { (_: Bool) in
            UIAccessibility.post(notification: .layoutChanged, argument: self)
            completion?(self)
        }
        if animated {
            view.layoutIfNeeded()
            imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            UIView.animate(withDuration: Constants.animationDurationForShow, delay: 0, usingSpringWithDamping: Constants.animationDampingRatio, initialSpringVelocity: 0, animations: {
                self.constraintWhenHidden.isActive = false
                self.constraintWhenShown.isActive = true
                self.imageView.transform = .identity
                view.layoutIfNeeded()
            }, completion: completionForShow)
        } else {
            completionForShow(true)
        }
    }

    /// `show` is used to present the view inside a container controller: insert into controller's view layout and show with optional animation. When container is a `UINavigationController` then its toolbar (if visible) is used as the bottom anchor for presentation. When container is `UITabBarController`, its tab bar is used as the anchor. Constraints are used for the view positioning.
    /// - Parameters:
    ///   - controller: The container controller whose view will be used for this view's presentation.
    ///   - animated: Indicates whether to use animation during presentation or not.
    ///   - completion: The closure to be called after presentation is completed. Can be used to call `hide` with a delay.
    public func show(from controller: UIViewController, animated: Bool = true, completion: ((ToastView) -> Void)? = nil) {
        if isShown {
            completion?(self)
            return
        }

        var anchorView: UIView?
        if let controller = controller as? UINavigationController, !controller.isToolbarHidden {
            anchorView = controller.toolbar
        }
        if let controller = controller as? UITabBarController {
            anchorView = controller.tabBar
        }

        show(in: controller.view, from: anchorView, animated: animated, completion: completion)
    }

    /// `hide` is used to dismiss the presented view: hide with optional animation and remove from the container.
    /// - Parameters:
    ///   - delay: The delay used for the start of dismissal. Default is 0.
    ///   - animated: Indicates whether to use animation during dismissal or not.
    ///   - completion: The closure to be called after dismissal is completed.
    public func hide(after delay: TimeInterval = 0, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.autoHideTimer = nil
        
        if !isShown || delay == .infinity {
            completion?()
            return
        }
        
        let actualDelay = delay == .LLPUI.autoHideDelay ? TimeInterval.smartDelay(for: configuration.richMessage?.attributedString.string ?? configuration.message) : delay
        if actualDelay > 0 {
            self.autoHideTimer = LLPUtils.Timer(interval: actualDelay) { [weak self] in
                guard let self = self else { return }
                
                self.hide(animated: animated, completion: completion)
            }
            self.autoHideTimer?.start()
            return
        }
        
        hapticFeedback = nil
        removeGestureRecognizers()

        if let completion = completion {
            completionsForHide.append(completion)
        }
        let completionForHide = {
            self.removeFromSuperview()

            self.completionsForHide.forEach { $0() }
            self.completionsForHide.removeAll()
        }
        if animated {
            if !isHiding {
                isHiding = true
        
                UIView.animate(withDuration: Constants.animationDurationForHide, animations: {
                    self.constraintWhenShown.isActive = false
                    self.constraintWhenHidden.isActive = true
                    self.superview?.layoutIfNeeded()
                    
                    self.backgroundView.alpha = 0
                    self.VContainer.alpha = 0
                }, completion: { _ in
                    self.backgroundView.alpha = 1
                    self.VContainer.alpha = 1
                    
                    self.isHiding = false
                    completionForHide()
                })
            }
        } else {
            completionForHide()
        }
    }


    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var suggestedWidth: CGFloat = size.width
        var availableLabelWidth = suggestedWidth

        if let windowWidth = window?.frame.width {
            suggestedWidth = windowWidth
        }

        // for iPad regular width size, notification toast might look too wide
        if traitCollection.userInterfaceIdiom == .pad &&
            traitCollection.horizontalSizeClass == .regular &&
            traitCollection.preferredContentSizeCategory < .accessibilityMedium {
            suggestedWidth = max(suggestedWidth / 2, 375.0)
        } else {
            suggestedWidth -= (safeAreaInsets.left + safeAreaInsets.right + 2 * Constants.presentationOffset)
        }
        suggestedWidth = ceil(suggestedWidth)
        availableLabelWidth = suggestedWidth
        
        let contentInsets = Constants.contentInset
        
        availableLabelWidth -= contentInsets.horizontal
        
        let imageSize = imageView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        availableLabelWidth -= (imageSize.width + Constants.horizontalSpacing)

        var suggesgedHeight: CGFloat = contentInsets.vertical
        let messagelabelSize = messageLabel.systemLayoutSizeFitting(CGSize(width: availableLabelWidth, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        suggesgedHeight += messagelabelSize.height

        if shouldShowActionButton {
            let availableButtonWidth = suggestedWidth - contentInsets.horizontal
            let buttonSize = actionButton.systemLayoutSizeFitting(CGSize(width: availableButtonWidth, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            suggesgedHeight += (buttonSize.height + Constants.verticalSpacing)
        }
        
        return CGSize(width: suggestedWidth, height: suggesgedHeight)
    }

    public override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    }

    private func update() {
        let style = configuration.style
        let message = configuration.message
        let richMessage = configuration.richMessage
        
        imageView.image = style.image
        
        let foregroundColor = style.foregroundColor
        imageView.tintColor = foregroundColor
        messageLabel.textColor = foregroundColor
    
        if let richMessage = richMessage {
            messageLabel.richText = richMessage
            messageLabel.isUserInteractionEnabled = true
        } else {
            messageLabel.text = message
        }
        
        if shouldShowActionButton {
            actionContainerView.isHidden = false
            actionButton.configuration.title = configuration.action?.title
        
        } else {
            actionContainerView.isHidden = true
        }
        
        VContainer.layoutMargins = effectiveContentInset
        
        backgroundView.configuration = .overlay(color: style.backgroundColor, cornerStyle: .fixed(.LLPUI.smallCornerRadius))
        
        invalidateIntrinsicContentSize()
    }

    private func setupHapticFeedback() {
        if let hapticFeedbackType = configuration.style.hapticFeedbackType {
            self.hapticFeedback = HapticFeedback(type: hapticFeedbackType)
            self.hapticFeedback?.prepare()
        }
        
    }
    
    private func setupGestureRecognizers() {
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(swipeGestureRecognizer)
        
    }
    
    private func removeGestureRecognizers() {
        removeGestureRecognizer(tapGestureRecognizer)
        removeGestureRecognizer(swipeGestureRecognizer)
    }

    @objc private func handleTap() {
        hide(animated: true)
    }

    @objc private func handleSwipe() {
        hide(animated: true)
    }
}


extension ToastView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view != actionButton
    }
}


public extension ToastView {
    
    func show(in view: UIView, from anchorView: UIView? = nil, animated: Bool = true) async {
        return await withCheckedContinuation { continuation in
            self.show(in: view, from: anchorView, animated: animated) { _ in
                continuation.resume()
            }
        }
    }
    
    func show(from controller: UIViewController, animated: Bool = true) async {
        return await withCheckedContinuation { continuation in
            self.show(from: controller, animated: animated) { _ in
                continuation.resume()
            }
        }
    }
    
    func hide(after delay: TimeInterval = 0, animated: Bool = true) async {
        await withCheckedContinuation { continuation in
            self.hide(after: delay, animated: animated) {
                continuation.resume()
            }
        }
    }
}

