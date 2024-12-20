//
//  UIViewControlller+ViewSizeTransition.swift
//  XUI
//
//  Created by xueqooy on 2023/8/16.
//

import Combine
import UIKit
import XKit

private extension UIViewController {
    @objc class func XUI_load_uiviewController_viewsizetransition() {
        setup_sizeTransition()
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
            overrideImplementation(Self.self, selector: #selector(Self.viewWillTransition(to:with:))) { _, originSelector, originIMPProvider in
                ({ (object: Self, size: CGSize, coordinator: UIViewControllerTransitionCoordinator) in
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (Self, Selector, CGSize, UIViewControllerTransitionCoordinator) -> Void).self)
                    oriIMP(object, originSelector, size, coordinator)

                    object.viewWillTransitionToSizeSubject.send((size, coordinator))
                } as @convention(block) (Self, CGSize, UIViewControllerTransitionCoordinator) -> Void)
            }
        }
    }
}
