//
//  PopupPresentationController.swift
//  LLPUI
//
//  Created by xueqooy on 2023/2/28.
//

import UIKit
import Combine

class PopupPresentationController: UIPresentationController {
    
    private lazy var dimmingView = BackgroundView(configuration: .dimmingBlack())
    
    private var keyboardManager: KeyboardManager?
    
    private var keyboardHeight: CGFloat = 0 {
        didSet {
            if keyboardHeight != oldValue {
                updateLayout(animated: true, animationDuration: keyboardAnimationDuration)
            }
        }
    }
    private var keyboardAnimationDuration: Double?
    
    private var cancellable: AnyCancellable?
    
    init(presentedViewController: UIViewController, presentingViewController: UIViewController?, adjustHeightForKeyboard: Bool) {
        
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
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        updateLayout()
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.addSubview(dimmingView)
        containerView?.addSubview(presentedViewController.view)
        
        updateLayout()
        
        dimmingView.alpha = 0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
    }
    
    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
    }
    
    func updateLayout(animated: Bool = false, animationDuration: TimeInterval? = nil) {
        guard let containerView = containerView, let presentedView = presentedView else {
            return
        }
        
        dimmingView.frame = containerView.bounds
        
        var contentBounds = containerView.bounds
        contentBounds = contentBounds
            .inset(by: containerView.safeAreaInsets)
            .insetBy(dx: 0, dy: .LLPUI.spacing5) // For iPhone landscape, ensure that the top and bottom do not stick to the edges
        
        
        let updatePresentedViewLayout = {
            let contentSize = self.presentedViewController.preferredContentSize.limit(to: contentBounds.size)
            let centerX = (0.5 * contentBounds.width + contentBounds.minX).floorInPixel()
            let centerY = (0.5 * contentBounds.height + contentBounds.minY).floorInPixel()
            
            presentedView.bounds = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
            presentedView.center = CGPoint(x: centerX, y: centerY)
            
            if self.keyboardHeight > 0 {
                // Make sure that the pop-up is not blocked by the keyboard
                let distanceToKeyboard = containerView.frame.maxY - presentedView.frame.maxY - self.keyboardHeight
                if distanceToKeyboard < 0 {
                    var updatedCenter = presentedView.center
                    updatedCenter.y += distanceToKeyboard
                    presentedView.center = updatedCenter
                    
                    // Make sure the top of the view does not exceed the boundary
                    let distanceToTopBound = presentedView.frame.minY - contentBounds.minY
                    if distanceToTopBound < 0 {
                        var updatedBounds = presentedView.bounds
                        var updatedCenter = presentedView.center
                        updatedBounds.size.height += distanceToTopBound
                        updatedCenter.y -= (distanceToTopBound * 0.5)
                        presentedView.bounds = updatedBounds
                        presentedView.center = updatedCenter
                    }
                }
            }
        }
        
        if animated {
            PopupTransitionAnimator.animateLayoutUpdate(updatePresentedViewLayout, duration: animationDuration)
        } else {
            updatePresentedViewLayout()
        }
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
        keyboardHeight = KeyboardManager.distanceFromMinYToBottom(of: containerView, keyboardRect: info.endFrame)
    }
}
