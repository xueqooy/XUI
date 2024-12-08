//
//  TouchForwardingView.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/9/21.
//

import UIKit

open class TouchForwardingView: UIView {
    var forwardsTouches: Bool = true
    var passthroughView: UIView?

    var onPassthroughViewTouches: ((_ point: CGPoint, _ event: UIEvent?) -> Void)?
    var onTouches: ((_ point: CGPoint, _ event: UIEvent?) -> Void)?

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if event?.type == .touches {
            onTouches?(point, event)
        }
        if forwardsTouches {
            return false
        }
        if let view = passthroughView {
            let localPoint = convert(point, to: view)
            if view.point(inside: localPoint, with: event) {
                if event?.type == .touches {
                    // Prevents the underlying (passthrough) view from getting touch events if there's custom code already handling it (onPassthroughViewTouches closure)
                    guard let onPassthroughViewTouches = onPassthroughViewTouches else {
                        return true
                    }
                    onPassthroughViewTouches(localPoint, event)
                }
                return false
            }
        }
        return super.point(inside: point, with: event)
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var hitTestView = super.hitTest(point, with: event)

        // Prevents the underlying (passthrough) view from getting touch events if there's custom code already handling it (onPassthroughViewTouches closure)
        guard onPassthroughViewTouches == nil else {
            return hitTestView
        }

        if let hitView = hitTestView, let passthroughView = passthroughView {
            let convertedPoint = hitView.convert(point, to: passthroughView)
            // checking which subview is eligible for the touch event
            hitTestView = passthroughView.hitTest(convertedPoint, with: event)
        }
        
        if hitTestView?.window != nil {
            return hitTestView
        } else {
            // Remove warning if hitTestView is not in window hierarchy
            return nil
        }

    }

}

