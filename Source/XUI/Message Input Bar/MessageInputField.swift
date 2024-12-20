//
//  MessageInputField.swift
//  XUI
//
//  Created by xueqooy on 2023/10/7.
//

import UIKit

public class MessageInputField: MultilineInputField {
    override public var recommendedAdditionalHeight: CGFloat {
        if traitCollection.verticalSizeClass == .regular {
            return (UIScreen.main.bounds.height / 14).rounded(.down)
        } else {
            return (UIScreen.main.bounds.height / 27).rounded(.down)
        }
    }

    override public init() {
        super.init()

        boxStackView.alignment = .center
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var defaultContentHeight: CGFloat {
        40.0
    }
}
