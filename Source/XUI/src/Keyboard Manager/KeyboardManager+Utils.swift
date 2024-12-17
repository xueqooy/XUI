//
//  KeyboardManager+Utils.swift
//  XUI
//
//  Created by xueqooy on 2023/8/1.
//

import UIKit


public extension KeyboardManager {
    
    static var keyboardView: UIView? {
        for window in UIApplication.shared.windows {
            if let view = keyboardView(in: window) {
                return view
            }
        }
        return nil
    }
    
    static var keyboardWindow: UIWindow? {
        for window in UIApplication.shared.windows {
            if let _ = keyboardView(in: window) {
                return window
            }
        }
        
        if let window = UIApplication.shared.windows.first(where: { window in
            NSStringFromClass(window.classForCoder) == "UIRemoteKeyboardWindow"
        }) {
            return window
        }
        
        if let window = UIApplication.shared.windows.first(where: { window in
            NSStringFromClass(window.classForCoder) == "UITextEffectsWindow"
        }) {
            return window
        }
        
        return nil
    }
    
    static func keyboardView(in window: UIWindow) -> UIView? {
        let windowName = NSStringFromClass(window.classForCoder)
        if windowName == "UIRemoteKeyboardWindow" {
            return window.subviews.first { subview in
                NSStringFromClass(subview.classForCoder) == "UIInputSetContainerView"
            }?.subviews.first { subview in
                NSStringFromClass(subview.classForCoder) == "UIInputSetHostView"
            }
        }
        if windowName == "UITextEffectsWindow" {
            return window.subviews.first { subview in
                NSStringFromClass(subview.classForCoder) == "UIInputSetContainerView"
            }?.subviews.first { subview in
                NSStringFromClass(subview.classForCoder) == "UIInputSetHostView"
            }
        }
        return nil
    }
    
    static var isKeyboardFloating: Bool {
        guard let keyboardView = keyboardView else {
            return false
        }
        
        return isFloatingKeyboard(keyboardView.bounds)
    }
    
    static var isKeyboardVisible: Bool {
        guard let keyboardView = self.keyboardView,
              let keyboardWindow = keyboardView.window else {
            return false
        }
        
        let rect = CGRectIntersection(keyboardWindow.bounds.flatInPixel(), keyboardView.frame.flatInPixel())
        if !rect.isEmpty && !rect.isValidated {
            return true
        }
        
        return false
    }
    
    static var currentKeyboardFrame: CGRect? {
        guard let keyboardView = self.keyboardView else {
            return nil
        }
        
        if let keyboardWindow = keyboardView.window {
            return keyboardWindow.convert(keyboardView.frame.flatInPixel(), to: nil)
        } else {
            return keyboardView.frame.flatInPixel()
        }
    }
    
    static var visibleKeyboardHeight: CGFloat {
        guard let keyboardView = self.keyboardView,
              let keyboardWindow = keyboardView.window else {
            return 0
        }
        
        // After the system's "Setting → Auxiliary Functions → Dynamic Effects → Reducing Dynamic Effects → Preferred Cross fade Transition Effect" is turned on, the keyboard animation is no longer a slide, but a fade, which should be judged by alpha
        if keyboardView.alpha <= 0 {
            return 0
        }
        
        let visibleRect = CGRectIntersection(keyboardWindow.bounds.flatInPixel(), keyboardView.frame.flatInPixel())
        if visibleRect.isValidated {
            return visibleRect.height
        }
        
        return 0
    }
    
    static func convertKeyboardRect(_ rect: CGRect, to view: UIView?) -> CGRect {
        if !rect.isValidated { return rect }
        
        guard let keyWindow = UIApplication.shared.keyWindows.first ?? UIApplication.shared.windows.first else {
            if let view = view {
                return view.convert(rect, from: nil)
            } else {
                return rect
            }
        }
        
        var rect = keyWindow.convert(rect, from: nil)
        guard let view = view, view !== keyWindow else {
            return rect
        }
                
        guard let toWindow = view as? UIWindow ?? view.window, toWindow !== keyWindow else {
            return keyWindow.convert(rect, to: view)
        }
        
        rect = keyWindow.convert(rect, to: keyWindow)
        rect = toWindow.convert(rect, from: keyWindow)
        rect = view.convert(rect, from: toWindow)
        
        return rect
    }
    
    static func distanceFromMinYToBottom(of view: UIView, keyboardRect: CGRect? = nil, respectsSafeArea: Bool = false, ignoresUndockedKeyboard: Bool = true) -> CGFloat {
        guard let keyboardRect = keyboardRect ?? currentKeyboardFrame else {
            return 0
        }
        
        if ignoresUndockedKeyboard && isFloatingKeyboard(keyboardRect) {
            return 0
        }
        
        let rectInView = convertKeyboardRect(keyboardRect, to: view)
        return view.bounds.flatInPixel().height - rectInView.minY - (respectsSafeArea ? view.safeAreaInsets.bottom : 0)
    }
    
    static func visibleRect(in view: UIView, keyboardRect: CGRect? = nil, ignoresUndockedKeyboard: Bool = true) -> CGRect? {
        guard let keyboardRect = keyboardRect ?? currentKeyboardFrame else {
            return nil
        }
        
        if ignoresUndockedKeyboard && isFloatingKeyboard(keyboardRect) {
            return nil
        }
        
        let rectInView = KeyboardManager.convertKeyboardRect(keyboardRect, to: view)
        let visibleRect = CGRectIntersection(view.bounds.flatInPixel(), rectInView.flatInPixel())
        if visibleRect.isValidated {
            return visibleRect
        }
        
        return nil
    }
    
    static var firstResponderInWindows: UIResponder? {
        if let responder = UIApplication.shared.keyWindows.first?.findFirstResponder()  {
            return responder
        }
        
        for window in UIApplication.shared.windows {
            if window != UIApplication.shared.keyWindows.first {
                if let responder = window.findFirstResponder() {
                    return responder
                }
            }
        }
        
        return nil
    }
    
    static internal func isLocalKeyboard(_ notification: Notification) -> Bool {
        if notification.userInfo?[UIApplication.keyboardIsLocalUserInfoKey] as? Bool == true {
            return true
        }
        
        if UIScreen.main.isSplitScreenIPad {
            return true
        }
        
        return false
    }
    
    static internal func isFloatingKeyboard(_ keyboardRect: CGRect) -> Bool {
        keyboardRect.width < (UIApplication.shared.keyWindows.first?.bounds.width ?? 0)
    }
}
