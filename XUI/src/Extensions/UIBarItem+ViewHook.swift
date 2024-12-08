//
//  UIBarItem+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2023/8/4.
//

import UIKit
import Combine
import XKit

private let viewSubjectAssociation = Association<CurrentValueSubject<UIView?, Never>>()

public extension UIBarItem {
    @objc private class func XUI_load_uibaritem_viewhook() {
        Once.execute("XUI_load_uibaritem_viewhook") {
            let sel = Selector(("setView:"))
            overrideImplementation(UIBarButtonItem.self, selector: sel) { originClass, originSelector, originIMPProvider in
                return ({ (object: UIBarButtonItem, view: UIView?) -> Void in
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (UIBarButtonItem, Selector, UIView?) -> Void).self)
                    oriIMP(object, originSelector, view)
                    
                    object.viewSubject.send(view)
                } as @convention(block) (UIBarButtonItem, UIView?) -> Void)
            }
            
            overrideImplementation(UITabBarItem.self, selector: sel) { originClass, originSelector, originIMPProvider in
                return ({ (object: UITabBarItem, view: UIView?) -> Void in
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (UITabBarItem, Selector, UIView?) -> Void).self)
                    oriIMP(object, originSelector, view)
                    
                    object.viewSubject.send(view)
                } as @convention(block) (UITabBarItem, UIView?) -> Void)
            }
        }
    }
    
    var view: UIView? {
        if self is UIBarButtonItem || self is UITabBarItem {
            return value(forKey: "view") as? UIView
        } else {
            return nil
        }
    }
    
    var viewPublisher: AnyPublisher<UIView?, Never> {
        viewSubject.removeDuplicates().eraseToAnyPublisher()
    }
    
    private var viewSubject: CurrentValueSubject<UIView?, Never> {
        if let subject = viewSubjectAssociation[self] {
            return subject
        }
        
        let subject = CurrentValueSubject<UIView?, Never>(view)
        viewSubjectAssociation[self] = subject
        
        return subject
    }
}
