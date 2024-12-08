//
//  ToastView.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/9/20.
//

import UIKit
import XKit

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
/// toastView.hide(after: .XUI.autoHideDelay)
/// ```
///
/// ```
/// In concurrency context:
///
/// await toastView.show(from: viewController, animated: true)
/// await toastView.hide(after: .XUI.autoHideDelay)
///
/// ```
///
///
/// The second way may result in the view not being hide automatically when already exists a notification view.
/// 

public class ToastView: UIView, Configurable {
    
    private struct Constants {
        static let horizontalSpacing: CGFloat = .XUI.spacing2
        static let verticalSpacing: CGFloat = .XUI.spacing3

        static let contentInset = UIEdgeInsets(top: .XUI.spacing4, left: .XUI.spacing4, bottom: .XUI.spacing4, right: .XUI.spacing4)
        static let presentationOffset: CGFloat = 20
        
        static let actionContainerHeight: CGFloat = 40
        
        static let animationDurationForShow: TimeInterval = 0.4
        static let animationDurationForHide: TimeInterval = 0.2
        static let animationDampingRatio: CGFloat = 0.5
    }
    
    public enum Style {
        case success
        case error
        case note
        case warning
        
        var backgroundColor: UIColor {
            switch self {
            case .success:
                Colors.lightGreen
            case .error:
                Colors.lightRed
            case .note:
                Colors.extraLightTeal
            case .warning:
                Colors.lightOrange
            }
        }
        
        var foregroundColor: UIColor {
            switch self {
            case .success:
                Colors.green
            case .error:
                Colors.red
            case .note:
                Colors.teal
            case .warning:
                Colors.orange
            }
        }
        
        var image: UIImage {
            switch self {
            case .success:
                Icons.checkCircle
            case .note:
                Icons.noteCircle
            case .warning, .error:
                Icons.warningCircle
            }
        }
        
        var prefixText: String {
            switch self {
            case .success:
                Strings.success
                
            case .error:
                Strings.error
                
            case .note:
                Strings.note
                
            case .warning:
                Strings.warning
            }
        }
        
        var hapticFeedbackType: HapticFeedbackType? {
            switch self {
            case .success:
                return .success
            case .error:
                return .error
            case .note:
                return nil
            case .warning:
                return .warning
            }
        }
    }
    
    public struct Configuration: Equatable, Then {

        public struct Action: Equatable {

            public let title: String
            public let color: UIColor
            public let handler: () -> Void
            
            private let identifier: UUID = .init()
            
            public init(title: String, color: UIColor = Colors.teal, handler: @escaping () -> Void) {
                self.title = title
                self.color = color
                self.handler = handler
            }
            
            public static func == (lhs: Configuration.Action, rhs: Configuration.Action) -> Bool {
                lhs.identifier == rhs.identifier
            }
        }
        
        public var style: Style
        public var message: String
        public var richMessage: RichText?
        public var primaryAction: Action?
        public var secondaryAction: Action?
        
        public var isEmptyMessage: Bool {
            if let richMessage = richMessage {
                return richMessage.length == 0
            } else {
                return message.isEmpty
            }
        }
        
        public init(style: Style = .success, message: String = "", richMessage: RichText? = nil, primaryAction: Action? = nil, secondaryAction: Action? = nil) {
            self.style = style
            self.message = message
            self.richMessage = richMessage
            self.primaryAction = primaryAction
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
        
    private var autoHideTimer: XKit.Timer?
    
    private let backgroundView = BackgroundView()
    
    private let VContainer = VStackView(spacing: .XUI.spacing2, layoutMargins: Constants.contentInset)
    
    private let HContainer = HStackView(distribution: .fill, alignment: .top, spacing: Constants.horizontalSpacing)
        .settingContentHuggingPriority(.required, for: .vertical)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let messageLabel = InsetLabel()
        messageLabel.inset = .nondirectional(top: 1, left: 0, bottom: 0, right: 0)
        if #available(iOS 14, *) {
            messageLabel.lineBreakStrategy = []
        }
        messageLabel.font = Fonts.body4
        messageLabel.textColor = Colors.title
        messageLabel.numberOfLines = 0
        messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        messageLabel.setContentHuggingPriority(.required, for: .vertical)
        return messageLabel
    }()
    
    private static let hideButtonImage = generateImageWithMargins(image: Icons.xmarkSmall, margins: .init(uniformValue: 3)).withRenderingMode(.alwaysTemplate)
    
    private lazy var hideButton = Button(configuration: .init(image: Self.hideButtonImage)) { [weak self] _ in
        self?.hide()
    }.settingContentCompressionResistanceAndHuggingPriority(.required)
    
    private lazy var primaryActionButton = Button(designStyle: .primary, contentInsetsMode: .override(.nondirectional(top: 0, left: 40, bottom: 0, right: 40)))
    
    private lazy var secondaryActionButton = Button(designStyle: .secondary, contentInsetsMode: .override(.nondirectional(top: 0, left: 40, bottom: 0, right: 40)))

    private lazy var actionContainerView = HStackView(spacing: .XUI.spacing4) { UIView() }
   
    private var constraintWhenHidden: NSLayoutConstraint!
    private var constraintWhenShown: NSLayoutConstraint!
            
    private var hapticFeedback: HapticFeedback?
    
    private var shouldShowPrimaryActionButton: Bool {
        configuration.primaryAction != nil && !configuration.primaryAction!.title.isEmpty
    }
    
    private var shouldShowSecondaryActionButton: Bool {
        configuration.secondaryAction != nil && !configuration.secondaryAction!.title.isEmpty
    }
    
    private var isDismissibleStyle: Bool = false
    
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
        
        setupDissmissibleStyle()

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
        
        let actualDelay = delay == .XUI.autoHideDelay ? TimeInterval.smartDelay(for: configuration.richMessage?.attributedString.string ?? configuration.message) : delay
        if actualDelay > 0 {
            self.autoHideTimer = XKit.Timer(interval: actualDelay) { [weak self] in
                guard let self = self else { return }
                
                self.hide(animated: animated, completion: completion)
            }
            self.autoHideTimer?.start()
            return
        }
        
        if let completion = completion {
            completionsForHide.append(completion)
        }
        let completionForHide = {
            self.removeDissmissibleStyle()
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

    private func update() {
        let style = configuration.style
        let message = configuration.message
        let richMessage = configuration.richMessage
        let foregroundColor = style.foregroundColor
        let shouldShowPrimaryActionButton = shouldShowPrimaryActionButton
        let shouldShowSecondaryActionButton = shouldShowSecondaryActionButton
        
        // Image
        imageView.image = style.image
        imageView.tintColor = foregroundColor
    
        
        // Message
        var fullMessageText: RichText = "\(style.prefixText + ": ", .foreground(style.foregroundColor), .font(Fonts.body4Bold))"
        
        if let richMessage = richMessage {
            fullMessageText = fullMessageText + richMessage
            
        } else {
            fullMessageText = fullMessageText + message
        }
        
        messageLabel.richText = fullMessageText
        
        
        // Action
        if shouldShowSecondaryActionButton {
            actionContainerView.insertArrangedSubview(secondaryActionButton, at: 0)

            secondaryActionButton.configuration.title = configuration.secondaryAction?.title
            (secondaryActionButton.configurationTransformer as! DesignedButtonConfigurationTransformer).mainColor = configuration.secondaryAction!.color
            secondaryActionButton.touchUpInsideAction = { [weak self] _ in
                guard let self, let action = self.configuration.secondaryAction else { return }
                
                action.handler()
            }
            secondaryActionButton.updateConfiguration()
            
        } else {
            secondaryActionButton.removeFromSuperview()
        }
        
        
        if shouldShowPrimaryActionButton {
            actionContainerView.insertArrangedSubview(primaryActionButton, at: 0)

            primaryActionButton.configuration.title = configuration.primaryAction?.title
            (primaryActionButton.configurationTransformer as! DesignedButtonConfigurationTransformer).mainColor = configuration.primaryAction!.color
            primaryActionButton.touchUpInsideAction = { [weak self] _ in
                guard let self, let action = self.configuration.primaryAction else { return }
                
                action.handler()
            }
            primaryActionButton.updateConfiguration()
            
        } else {
            primaryActionButton.removeFromSuperview()
        }
    
        actionContainerView.isHidden = !(shouldShowPrimaryActionButton || shouldShowSecondaryActionButton)
        
            
        // Background
        backgroundView.configuration = .init(fillColor: style.backgroundColor, cornerStyle: .fixed(.XUI.smallCornerRadius))
    }
    
    private func setupDissmissibleStyle() {
        isDismissibleStyle = true
        
        translatesAutoresizingMaskIntoConstraints = false
                
        if let hapticFeedbackType = configuration.style.hapticFeedbackType {
            self.hapticFeedback = HapticFeedback(type: hapticFeedbackType)
            self.hapticFeedback?.prepare()
        }
        
        backgroundView.update {
            $0.stroke.color = configuration.style.foregroundColor
            $0.stroke.width = 1
        }
    
        hideButton.configuration.foregroundColor = configuration.style.foregroundColor
        HContainer.addArrangedSubview(hideButton)
    }

    private func removeDissmissibleStyle() {
        isDismissibleStyle = false
        
        backgroundView.update {
            $0.stroke.color = nil
            $0.stroke.width = 0
        }
        
        hideButton.removeFromSuperview()
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


