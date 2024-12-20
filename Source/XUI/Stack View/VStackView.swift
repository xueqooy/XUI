//
//  VStackView.swift
//  XUI
//
//  Created by xueqooy on 2023/11/3.
//

import UIKit

public class VStackView: StackView {
    override public var axis: NSLayoutConstraint.Axis {
        willSet {
            precondition(newValue == .vertical, "VStack can't modify its axis as horizontal")
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        axis = .vertical
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
