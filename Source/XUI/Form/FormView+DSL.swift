//
//  FormView+DSL.swift
//  XUI
//
//  Created by xueqooy on 2023/8/2.
//

import UIKit
import XKit

public protocol FormComponent {
    func asFormItems() -> [FormItem]
}

extension FormItem: FormComponent {
    public func asFormItems() -> [FormItem] {
        [self]
    }
}

public extension FormView {
    func populate(keepPreviousItems: Bool = false, @ArrayBuilder<FormComponent> components: () -> [FormComponent]) {
        if !keepPreviousItems {
            removeAllItems()
        }

        components()
            .flatMap { $0.asFormItems() }
            .forEach { addItem($0) }
    }
}
