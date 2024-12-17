//
//  CoachmarkController+Helper.swift
//  XUI
//
//  Created by xueqooy on 2023/8/4.
//

import UIKit
import XKit

public extension CoachmarkController {
    func coachmarkRect(for anchorView: UIView, insets: UIEdgeInsets = .zero) -> CGRect {
        coachmarkRect(for: anchorView.bounds, in: anchorView, insets: insets)
    }
    
    func coachmarkRect(for barButtonItem: UIBarButtonItem, insets: UIEdgeInsets = .zero) -> CGRect {
        guard let view = barButtonItem.view else {
            Logs.warn("The view was not found in barButtonItem", tag: "XUI.Coachmark")
            return .zero
        }
        
        return coachmarkRect(for: view, insets: insets)
    }
    
    func coachmarkRect(for tabBarItem: UITabBarItem, insets: UIEdgeInsets = .zero) -> CGRect {
        guard let view = tabBarItem.view else {
            Logs.warn("The view was not found in tabBarItem", tag: "XUI.Coachmark")
            return .zero
        }

        return coachmarkRect(for: view, insets: insets)
    }
    
    func coachmarkRect(for rect: CGRect, in view: UIView, insets: UIEdgeInsets) -> CGRect {
        guard let coachmarkWindow = window, let viewController = viewController else {
            Logs.warn("CoachmarkController did not started", tag: "XUI.Coachmark")
            return .zero
        }
        
        guard let anchorWindow = view.window else {
            Logs.warn("Anchor view isn't in view hierarchy", tag: "XUI.Coachmark")
            return .zero
        }
        
        // 1. Converts the coordinates of the frame from anchor to its window.
        let anchorRectInAnchorWindow = view.convert(rect, to: anchorWindow)
        
        guard anchorWindow != coachmarkWindow else {
            return anchorRectInAnchorWindow
        }
        
        // 2. Converts the coordinates of the frame from anchor's window to coachmark' window.
        let anchorRectInCoachmarkWindow = coachmarkWindow.convert(anchorRectInAnchorWindow, from: anchorWindow)
        
        // 3. Converts the coordinates of the frame from coachmark's window to viewController's view.
        return viewController.view.convert(anchorRectInCoachmarkWindow, from: anchorWindow).inset(by: insets)
    }
}
