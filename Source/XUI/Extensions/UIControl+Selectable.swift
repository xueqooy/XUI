//
//  UIControl+Selectable.swift
//  XUI
//
//  Created by xueqooy on 2023/8/1.
//

import Combine
import UIKit
import XKit

private extension UIControl {
    @objc class func XUI_load_uicontrol_selectable() {
        Once.execute("XUI_load_uicontrol_selectable") {
            overrideImplementation(Self.self, selector: #selector(setter: Self.isSelected)) { _, originSelector, originIMPProvider in
                ({ (object: Self, isSelected: Bool) in
                    let oldValue = object.isSelected

                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (Self, Selector, Bool) -> Void).self)
                    oriIMP(object, originSelector, isSelected)

                    guard oldValue != isSelected else {
                        return
                    }

                    object.isSelectedSubject.send(isSelected)
                } as @convention(block) (Self, Bool) -> Void)
            }
        }
    }
}

private let isSelectedSubjectAssociation = Association<CurrentValueSubject<Bool, Never>>()

extension UIControl: Selectable {
    private var isSelectedSubject: CurrentValueSubject<Bool, Never> {
        if let subject = isSelectedSubjectAssociation[self] {
            return subject
        }

        let subject = CurrentValueSubject<Bool, Never>(isSelected)
        isSelectedSubjectAssociation[self] = subject

        return subject
    }

    public var isSelectedPublisher: AnyPublisher<Bool, Never> {
        isSelectedSubject.eraseToAnyPublisher()
    }
}
