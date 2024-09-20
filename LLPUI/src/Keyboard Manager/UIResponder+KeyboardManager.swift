//
//  UIResponder+KeyboardManager.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/1.
//

import LLPUtils
import UIKit

private let isFirstResponderAssociation = Association<Bool>()

/// The system's own isFirstResponder is delayed. Here we can manually record whether the UIResponder is isFirstResponder.
extension UIResponder {
    var keyboardManager_isFirstResponder: Bool {
        get {
            isFirstResponderAssociation[self] ?? false
        }
        set {
            isFirstResponderAssociation[self] = newValue
        }
    }
        
    static func setup_keyboardManager_isFirstResponder() {
        Once.execute("KeyboardManager_setup_keyboardManager_isFirstResponder") {
            overrideImplementation(UIResponder.self, selector: #selector(UIResponder.becomeFirstResponder)) { originClass, originSelector, originIMPProvider in
                return ({ (object: AnyObject) -> Bool in
                    (object as? UIResponder)?.keyboardManager_isFirstResponder = true
                    
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (AnyObject, Selector) -> Bool).self)
                    let result = oriIMP(object, originSelector)
                    
                    return result
                } as @convention(block) (AnyObject) -> Bool)
            }
            
            overrideImplementation(UIResponder.self, selector: #selector(UIResponder.resignFirstResponder)) { originClass, originSelector, originIMPProvider in
                return ({ (object: AnyObject) -> Bool in
                    (object as? UIResponder)?.keyboardManager_isFirstResponder = false
                    
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (AnyObject, Selector) -> Bool).self)
                    let result = oriIMP(object, originSelector)
                    
                    return result
                } as @convention(block) (AnyObject) -> Bool)
            }
        }
    }
}


