//
//  NestedParentScrollView.swift
//  XUI
//
//  Created by xueqooy on 2023/7/20.
//

import UIKit

class NestedParentScrollView: UIScrollView, UIGestureRecognizerDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        alwaysBounceVertical = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }

    var nonSimultaneousGestureRecognizers = [UIGestureRecognizer]()

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        !nonSimultaneousGestureRecognizers.contains(otherGestureRecognizer)
    }
}
