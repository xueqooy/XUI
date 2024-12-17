//
//  UIView+EndEditingTapGesture.swift
//  XUI
//
//  Created by xueqooy on 2023/10/11.
//

import UIKit
import XKit

public class EndEditingTapGestureRecognizer: UITapGestureRecognizer {
    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        
        cancelsTouchesInView = false
    }
}

public extension UIView {
    private struct Associations {
        static let endEditingTapGestureRecognizer = Association<EndEditingTapGestureRecognizer>()
        static let endEditingTapGestureRecognizerDelegate = Association<EndEditingTapGestureRecognizerDelegate>()
        static let shouldRespondToEndEditingTapGestrueWhenTappingOnView = Association<(UIView) -> Bool>(wrap: .retain)
        static let endEditingOverride = Association<() -> Void>(wrap: .retain)
    }
    
    var isEndEditingTapGestureEnabled: Bool {
        set {
            if newValue {
                // Setup gesture
                endEditingTapGestureRecognizer.isEnabled = true
                addGestureRecognizer(endEditingTapGestureRecognizer)
            } else if isEndEditingTapGestureEnabled {
                // Disable gesture
                endEditingTapGestureRecognizer.isEnabled = false
            }
        }
        get {
            if let gestureRecognizer = Associations.endEditingTapGestureRecognizer[self], gestureRecognizer.isEnabled, gestureRecognizer.view != nil {
                return true
            } else {
                return false
            }
        }
    }
    
    /// Default(nil) not to respond to the gesture when tapping on a control
    var shouldRespondToEndEditingTapGestrueWhenTappingOnView: ((UIView) -> Bool)? {
        set {
            endEditingTapGestureRecognizerDelegate.shouldRespondToEndEditingTapGestrueWhenTappingOnView = newValue
        }
        get {
            endEditingTapGestureRecognizerDelegate.shouldRespondToEndEditingTapGestrueWhenTappingOnView
        }
    }
    
    var endEditingOverride: (() -> Void)? {
        set { Associations.endEditingOverride[self] = newValue }
        get { Associations.endEditingOverride[self] }
    }
    
    /// Lazy load
    private var endEditingTapGestureRecognizer: UITapGestureRecognizer {
        var gestureRecognizer = Associations.endEditingTapGestureRecognizer[self]
        if gestureRecognizer == nil {
            gestureRecognizer = EndEditingTapGestureRecognizer(target: self, action: #selector(Self.endEditingTapGestureAction))
            gestureRecognizer!.delegate = endEditingTapGestureRecognizerDelegate
        
            Associations.endEditingTapGestureRecognizer[self] = gestureRecognizer
        }
        
        return gestureRecognizer!
    }
    
    /// Lazy load
    private var endEditingTapGestureRecognizerDelegate: EndEditingTapGestureRecognizerDelegate {
        var delegate = Associations.endEditingTapGestureRecognizerDelegate[self]
        if delegate == nil {
            delegate = EndEditingTapGestureRecognizerDelegate()
            Associations.endEditingTapGestureRecognizerDelegate[self] = delegate
        }
        return delegate!
    }
    
    @objc func endEditingTapGestureAction() {
        if let endEditingOverride = Associations.endEditingOverride[self] {
            endEditingOverride()
        } else {
            UIApplication.shared.keyWindows.first?.endEditing(true)
        }
    }
    
}

private class EndEditingTapGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    var shouldRespondToEndEditingTapGestrueWhenTappingOnView: ((UIView) -> Bool)?
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            if let shouldRespondToEndEditingTapGestrueWhenTappingOnView = shouldRespondToEndEditingTapGestrueWhenTappingOnView {
                return shouldRespondToEndEditingTapGestrueWhenTappingOnView(view)
            } else if view is UIControl {
                return false
            }
        }
    
        return true
    }
}
