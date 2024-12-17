//
//  UIView+CustomSpacingAfter.swift
//  XUI
//
//  Created by xueqooy on 2023/11/4.
//

import UIKit
import XKit

private let customSpacingAfterAssociation = Association<CGFloat>()


/**
 Used to set custom spacing after in `StackView` and` FormRow`(multiple views)
 */
public extension UIView {
    internal var customSpacingAfter: CGFloat? {
        set {
            customSpacingAfterAssociation[self] = newValue
            
            maybeApplyCustomSpacingAfter()
        }
        get {
            customSpacingAfterAssociation[self]
        }
    }
    
    internal func maybeApplyCustomSpacingAfter() {
        guard let stack = superview as? UIStackView, let customSpacingAfter = customSpacingAfter else {
            return
        }
        
        stack.setCustomSpacing(customSpacingAfter, after: self)
        customSpacingAfterAssociation[self] = nil
    }
}
