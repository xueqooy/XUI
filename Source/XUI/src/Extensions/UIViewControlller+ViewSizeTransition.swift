//
//  UIViewControlller+SizeTransition.swift
//  XUI
//
//  Created by xueqooy on 2023/8/16.
//

import UIKit
import XKit
import Combine

private extension UIViewController {
    @objc class func XUI_load_uiviewController_viewsizetransition() {
        Self.setup_sizeTransition()
    }
}

private let viewWillTransitionToSizeSubjectAssociation = Association<PassthroughSubject<(CGSize, UIViewControllerTransitionCoordinator), Never>>()

public extension UIViewController {
    private var viewWillTransitionToSizeSubject: PassthroughSubject<(CGSize, UIViewControllerTransitionCoordinator), Never> {
        if let subject = viewWillTransitionToSizeSubjectAssociation[self] {
            return subject
        }
        
        let subject = PassthroughSubject<(CGSize, UIViewControllerTransitionCoordinator), Never>()
        viewWillTransitionToSizeSubjectAssociation[self] = subject
        
        return subject
    }
    
    var viewWillTransitionToSizePublisher: AnyPublisher<(CGSize, UIViewControllerTransitionCoordinator), Never> {
        viewWillTransitionToSizeSubject.eraseToAnyPublisher()
    }
    
    private class func setup_sizeTransition() {
        Once.execute("UIViewController+Extensions_setup_viewSizeTransition") {
            overrideImplementation(Self.self, selector: #selector(Self.viewWillTransition(to:with:))) { originClass, originSelector, originIMPProvider in
                return ({ (object: Self, size: CGSize, coordinator: UIViewControllerTransitionCoordinator) -> Void in
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (Self, Selector, CGSize, UIViewControllerTransitionCoordinator) -> Void).self)
                    oriIMP(object, originSelector, size, coordinator)
                    
                    object.viewWillTransitionToSizeSubject.send((size, coordinator))
                } as @convention(block) (Self, CGSize, UIViewControllerTransitionCoordinator) -> Void)
            }
        }
    }

}
