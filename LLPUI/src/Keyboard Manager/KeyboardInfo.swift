//
//  KeyboardInfo.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/21.
//

import UIKit

public struct KeyboardInfo {
    public weak var targetResponder: UIResponder?
    public var notification: Notification?
    public var beginFrame: CGRect?
    public var endFrame: CGRect?
    public var animationDuration: TimeInterval?
    public var animationCurve: UIView.AnimationCurve?
    public var animationOptions: UIView.AnimationOptions?
    public var isLocal: Bool?
    
    public var width: CGFloat? {
        guard let endFrame = endFrame else {
            return nil
        }
        
        return KeyboardManager.convertKeyboardRect(endFrame, to: nil).width
    }
    
    public var height: CGFloat? {
        guard let endFrame = endFrame else {
            return nil
        }
        
        return KeyboardManager.convertKeyboardRect(endFrame, to: nil).height
    }
    

    init(notification: Notification, targetResponder: UIResponder?) {
        self.notification = notification
        self.targetResponder = targetResponder
        
        let userInfo = notification.userInfo
      
        beginFrame = userInfo?[UIApplication.keyboardFrameBeginUserInfoKey] as? CGRect
        endFrame = userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect
        animationDuration = userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        isLocal = userInfo?[UIApplication.keyboardIsLocalUserInfoKey] as? Bool
        var animationCurve: UIView.AnimationCurve?
        if let animationCurveRawValue = userInfo?[UIApplication.keyboardAnimationCurveUserInfoKey] as? Int {
            animationCurve = UIView.AnimationCurve(rawValue: animationCurveRawValue)
            self.animationCurve = animationCurve
        } else {
            self.animationCurve = nil
        }
        if let animationCurve = animationCurve {
            animationOptions = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue) << 16)
        } else {
            animationOptions = nil
        }
    }
    
    init() {
    }
}
