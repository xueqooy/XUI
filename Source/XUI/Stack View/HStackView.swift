//
//  HStackView.swift
//  XUI
//
//  Created by xueqooy on 2023/11/3.
//

import UIKit

public class HStackView: StackView {
    override public var axis: NSLayoutConstraint.Axis {
        willSet {
            precondition(newValue == .horizontal, "HStack can't modify its axis as vertical")
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        axis = .horizontal
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
