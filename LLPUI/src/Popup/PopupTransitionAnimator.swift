//
//  PopupTransitionAnimator.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/3.
//

import UIKit

class PopupTransitionAnimator: NSObject {
    struct Constants {
        static let presentationInDuration: TimeInterval = 0.15
        static let presentationOutDuration: TimeInterval = 0.1
        static let presentationInScale: CGFloat = 0.65
        static let presentationOutScale: CGFloat = 0.9
        static let animationDurationWhenLayoutUpdated: TimeInterval = 0.25
    }
    
    private let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting

        super.init()
    }
    
    static func animateLayoutUpdate(_ animation: @escaping () -> Void, duration: TimeInterval? = nil) {
        UIView.animate(withDuration: duration ?? Constants.animationDurationWhenLayoutUpdated, delay: 0, options: [.layoutSubviews, .curveEaseOut], animations: animation)
    }

    private func present(withTransitionContext transitionContext: UIViewControllerContextTransitioning, completion: @escaping (Bool) -> Void) {
        let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to)!

        // Animation start state
        presentedView.alpha = 0
        presentedView.layoutIfNeeded()
        presentedView.transform = CGAffineTransform(scaleX: Constants.presentationInScale, y: Constants.presentationInScale)

        // Start animation
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            // Animation end state
            presentedView.transform = CGAffineTransform.identity
            presentedView.alpha = 1
        }, completion: completion)
    }

    private func dismiss(withTransitionContext transitionContext: UIViewControllerContextTransitioning, completion: @escaping (Bool) -> Void) {
        let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
  
        // Start animation
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            // Animation end state
            presentedView.transform = CGAffineTransform(scaleX: Constants.presentationOutScale, y: Constants.presentationOutScale)
            presentedView.alpha = 0
        }, completion: completion)
    }
}


extension PopupTransitionAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresenting ? Constants.presentationInDuration : Constants.presentationOutDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            present(withTransitionContext: transitionContext) { finished in
                transitionContext.completeTransition(finished)
            }
        } else {
            dismiss(withTransitionContext: transitionContext) { finished in
                transitionContext.completeTransition(finished)
            }
        }
    }
}
