//
//  InsetTextField.swift
//  XUI
//
//  Created by xueqooy on 2023/2/23.
//

import UIKit

open class InsetTextField: UITextField {
    public var inset: Insets = .nondirectionalZero {
        didSet {
            setNeedsDisplay()
        }
    }

    private var effectiveInset: UIEdgeInsets {
        inset.edgeInsets(for: effectiveUserInterfaceLayoutDirection)
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = bounds.inset(by: effectiveInset)
        return super.textRect(forBounds: bounds)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = bounds.inset(by: effectiveInset)
        return super.editingRect(forBounds: bounds)
    }
}
