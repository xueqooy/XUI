//
//  FormSeparator.swift
//  XUI
//
//  Created by xueqooy on 2023/3/6.
//

import UIKit
import XKit

public class FormSeparator: FormItem {
    @EquatableState
    public var leadingPadding: CGFloat {
        didSet {
            (loadedView as? FormSeparatorView)?.leadingPadding = leadingPadding
        }
    }

    @EquatableState
    public var trailingPadding: CGFloat {
        didSet {
            (loadedView as? FormSeparatorView)?.trailingPadding = trailingPadding
        }
    }

    public init(leadingPadding: CGFloat = 0, trailingPadding: CGFloat = 0) {
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding

        super.init()
    }

    override func createView() -> UIView {
        FormSeparatorView(leadingPadding: leadingPadding, trailingPadding: trailingPadding)
    }
}

class FormSeparatorView: HSeparatorView {}
