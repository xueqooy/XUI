//
//  Popover.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/10/18.
//

import UIKit
import LLPUtils

// TODO: Support re-position

/// A popover with arrow to display its content through `contentView`
open class Popover: Configurable {
    
    public enum DismissMode: Equatable {
        case none
        case tapOnSuperview
        case tapOnOutsidePopover
        case tapOnOutsidePopoverAndAnchor
        case tapOnPopover
        case tapOnPopoverOrAnchor
    }
    
    public enum AnimationTransition {
        case zoom
        case push
    }
    
    public typealias TapPointProvider = (UIView) -> CGPoint?
    public typealias HiddenConfirmationHandler = (TapPointProvider) -> Bool
    
    public struct Configuration {
        public var dismissMode: DismissMode = .none
        /// When `delayHideOnAnchor` is true, tapping on anchorView will delay hiding, which will prevent touch event from being passed to anchorView
        public var delayHidingOnAnchor: Bool = false
        public var background: BackgroundConfiguration = .overlay(color: .white, cornerStyle: .fixed(.LLPUI.smallCornerRadius))
        public var preferredDirection: Direction = .down
        public var contentInsets: UIEdgeInsets = .init(uniformValue: .LLPUI.spacing4)
        public var superviewMargins: UIEdgeInsets = .init(uniformValue: .LLPUI.spacing4)
        public var offset: CGPoint = .zero
        public var arrowSize: CGSize = CGSize(width: 16, height: 10)
        public var animationInDuration: TimeInterval = 0.15
        public var animationOutDuration: TimeInterval = 0.1
        public var animationTransition: AnimationTransition = .zoom
        public var maximumContentWidth: CGFloat? = nil
        public var maximumContentHeight: CGFloat? = nil
        /// Content view always does not exceed boundaries of superview if `true`
        public var limitsToBounds: Bool = true
        
        
        public init(dismissMode: DismissMode = .none, 
                    background: BackgroundConfiguration = .overlay(color: .white, cornerStyle: .fixed(.LLPUI.smallCornerRadius)),
                    preferredDirection: Direction = .down,
                    contentInsets: UIEdgeInsets = .init(uniformValue: .LLPUI.spacing4),
                    superviewMargins: UIEdgeInsets = .init(uniformValue: .LLPUI.spacing4),
                    offset: CGPoint = .zero,
                    arrowSize: CGSize = CGSize(width: 16, height: 10),
                    animationInDuration: TimeInterval = 0.15,
                    animationOutDuration: TimeInterval = 0.1,
                    animationTransition: AnimationTransition = .zoom,
                    maximumContentWidth: CGFloat? = nil,
                    maximumContentHeight: CGFloat? = nil,
                    limitsToBounds: Bool = true) {
            self.dismissMode = dismissMode
            self.background = background
            self.preferredDirection = preferredDirection
            self.contentInsets = contentInsets
            self.superviewMargins = superviewMargins
            self.offset = offset
            self.arrowSize = arrowSize
            self.animationInDuration = animationInDuration
            self.animationOutDuration = animationOutDuration
            self.animationTransition = animationTransition
            self.maximumContentWidth = maximumContentWidth
            self.maximumContentHeight = maximumContentHeight
            self.limitsToBounds = limitsToBounds
        }
    }
    
    public var configuration: Configuration
    
    @EquatableState
    public private(set) var isShowing: Bool = false
    
    private var contentController: UIViewController?
    private var containerView: PopoverContainerView?
    private var shouldHide: HiddenConfirmationHandler?
    private var gestureView: UIView?
    
    public init(configuration: Popover.Configuration = Popover.Configuration()) {
        self.configuration = configuration
    }
    
    
    public func show(_ contentController: UIViewController, preferredContentSize: CGSize? = nil, in superController: UIViewController? = nil, from anchorView: UIView, animated: Bool = true, shouldHide: HiddenConfirmationHandler? = nil, completion: (() -> Void)? = nil) {
        let contentView = contentController.view!
        let superview = superController?.view
    
        show(contentView, preferredContentSize: preferredContentSize ?? contentController.preferredContentSize, in: superview, from: anchorView, animated: animated, shouldHide: shouldHide, completion: completion)
        
        let superController = superController ?? anchorView.window?.rootViewController
        superController?.addChild(contentController)
        contentController.didMove(toParent: superController)
        
        self.contentController = contentController
    }
    
    public func show(_ contentView: UIView, preferredContentSize: CGSize? = nil, in superview: UIView? = nil, from anchorView: UIView, animated: Bool = true, shouldHide: HiddenConfirmationHandler? = nil, completion: (() -> Void)? = nil) {
        hide(animated: animated)
        
        guard let superview = superview ?? anchorView.window else {
            preconditionFailure("Can't determine superview")
        }
        
        let containerView = PopoverContainerView(contentView: contentView, configuration: configuration)
        
        self.containerView = containerView
    
        if configuration.dismissMode != .none {
            self.shouldHide = shouldHide
            // Add tap gesture
            let gestureView = TouchForwardingView(frame: superview.bounds)
            self.gestureView = gestureView
            
            switch configuration.dismissMode {
            case .tapOnSuperview:
                superview.addSubview(containerView)
                superview.addSubview(gestureView)
                gestureView.forwardsTouches = false
                gestureView.onTouches = { [weak anchorView] point, _ in
                    self.tapGestureView(at: point, anchorView: anchorView)
                }
                
            case .tapOnPopover, .tapOnPopoverOrAnchor:
                superview.addSubview(gestureView)
                superview.addSubview(containerView)
                gestureView.forwardsTouches = false
                containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.handleTapGesture)))
                if configuration.dismissMode == .tapOnPopoverOrAnchor {
                    gestureView.passthroughView = anchorView
                    gestureView.onPassthroughViewTouches = { [weak anchorView] point, _ in
                        self.tapGestureView(at: point, anchorView: anchorView)
                    }
                }
                
            case .tapOnOutsidePopover:
                superview.addSubview(gestureView)
                superview.addSubview(containerView)
                gestureView.forwardsTouches = false            
                gestureView.onTouches = { [weak anchorView] point, _ in
                    self.tapGestureView(at: point, anchorView: anchorView)
                }
                
            case .tapOnOutsidePopoverAndAnchor:
                superview.addSubview(gestureView)
                superview.addSubview(containerView)
                gestureView.forwardsTouches = false
                gestureView.onTouches = { [weak gestureView, weak anchorView] point, _ in
                    guard let gestureView, let anchorView  else {
                        self.tapGestureView(at: point)
                        return
                    }
                    
                    let pointInAnchorView = gestureView.convert(point, to: anchorView)
                    if anchorView.bounds.contains(pointInAnchorView) {
                        return
                    }
                    
                    self.tapGestureView(at: point, anchorView: anchorView)
                }
            default: break
            }
        } else {
            superview.addSubview(containerView)
        }
        
        let positionController = PopoverPositionController(contentView: contentView, preferredContentSize: preferredContentSize ?? .zero, superview: superview, anchorView: anchorView, configuration: configuration)
                
        // Layout popover
        containerView.layer.anchorPoint = positionController.popoverAnchorPoint
        containerView.frame = positionController.popoverRect
        containerView.positionController = positionController

        if animated {
            // Animate popover
            containerView.alpha = 0.0
            
            switch configuration.animationTransition {
            case .zoom:
                containerView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            case .push:
                containerView.transform = CGAffineTransform(scaleX: 1.0, y: 0.0)
            }
            
            UIView.animate(withDuration: configuration.animationInDuration, delay: 0, options: [.curveEaseOut]) {
                containerView.alpha = 1.0
                containerView.transform = .identity
                
            } completion: { _ in
                completion?()
            }
        } else {
            completion?()
        }
        
        isShowing = true
    }
    
    public func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        gestureView?.removeFromSuperview()
        gestureView = nil
        
        guard let containerView = containerView else {
            completion?()
            return
        }
        
        if animated {
            // Animate popover
            UIView.animate(withDuration: configuration.animationOutDuration, delay: 0, options: [.beginFromCurrentState, .curveEaseIn]) {
                containerView.alpha = 0.0
                
                switch self.configuration.animationTransition {
                case .zoom:
                    containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                case .push:
                    containerView.transform = CGAffineTransform(scaleX: 1.0, y: 0.1)
                }
                
            } completion: { [weak self] _ in
                self?.contentController?.willMove(toParent: nil)
                containerView.removeFromSuperview()
                self?.contentController?.removeFromParent()
                
                completion?()
            }
        } else {
            contentController?.willMove(toParent: nil)
            containerView.removeFromSuperview()
            contentController?.removeFromParent()
            
            completion?()
        }
        
        self.containerView = nil
        contentController = nil
        shouldHide = nil
        isShowing = false
    }
    
    private func tapGestureView(at point: CGPoint, anchorView: UIView? = nil) {
        lazy var tapPointProvider: TapPointProvider = { [weak self] view in
            guard let self, let gestureView = self.gestureView else {
                return nil
            }
            
            return gestureView.convert(point, to: view)
        }
    
        if configuration.delayHidingOnAnchor, let gestureView, let anchorView {
            let pointInAnchorView = gestureView.convert(point, to: anchorView)
            if anchorView.bounds.contains(pointInAnchorView) {
                Queue.main.execute(.delay(0.01)) { [weak self] in
                    guard let self else { return }
                    
                    if self.shouldHide?(tapPointProvider) ?? true {
                        self.hide()
                    }
                }
                return
            }
        }
        
        if shouldHide?(tapPointProvider) ?? true {
            hide()
        }
    }
    
    @objc private func handleTapGesture(_ sender: UIGestureRecognizer) {
        lazy var tapPointProvider: TapPointProvider = { view in
            return sender.location(in: view)
        }
        
        if shouldHide?(tapPointProvider) ?? true {
            hide()
        }
    }
}
