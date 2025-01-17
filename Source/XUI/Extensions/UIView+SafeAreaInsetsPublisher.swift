//
//  UIView+SafeAreaInsetsPublisher.swift
//  llp_x_cloud_assemble_ios
//
//  Created by xueqooy on 2024/10/19.
//

import Combine
import UIKit
import XKit

private extension UIView {
    @objc class func XUI_load_uiview_safeareainsetspublisher() {
        setup_safeAreaInsetsPublisher()
    }
}

private let safeAreaInsetsSubjectAssociation = Association<CurrentValueSubject<UIEdgeInsets, Never>>()

public extension UIView {
    private var safeAreaInsetsSubject: CurrentValueSubject<UIEdgeInsets, Never> {
        if let subject = safeAreaInsetsSubjectAssociation[self] {
            return subject
        }

        let subject = CurrentValueSubject<UIEdgeInsets, Never>(safeAreaInsets)
        safeAreaInsetsSubjectAssociation[self] = subject

        return subject
    }

    var safeAreaInsetsPublisher: AnyPublisher<UIEdgeInsets, Never> {
        safeAreaInsetsSubject.eraseToAnyPublisher()
    }

    private class func setup_safeAreaInsetsPublisher() {
        Once.execute("UIViewController+SafeAreaInsetsPublisher_setup_safeAreaInsetsPublisher") {
            overrideImplementation(Self.self, selector: #selector(Self.safeAreaInsetsDidChange)) { _, originSelector, originIMPProvider in
                ({ (object: Self) in
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (Self, Selector) -> Void).self)
                    oriIMP(object, originSelector)

                    object.safeAreaInsetsSubject.send(object.safeAreaInsets)
                } as @convention(block) (Self) -> Void)
            }
        }
    }
}
