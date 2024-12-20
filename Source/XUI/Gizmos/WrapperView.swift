//
//  WrapperView.swift
//  XUI
//
//  Created by xueqooy on 2023/4/10.
//

import SnapKit
import UIKit

/// Wrap a view, adjust content margins by setting `layoutMargins`
public class WrapperView: UIView {
    var intrinsicSize: CGSize? {
        didSet {
            if oldValue == intrinsicSize {
                return
            }

            invalidateIntrinsicContentSize()
        }
    }

    public init(_ view: UIView, layoutMargins: UIEdgeInsets = .zero, intrinsicSize: CGSize? = nil) {
        super.init(frame: .zero)

        self.layoutMargins = layoutMargins
        self.intrinsicSize = intrinsicSize

        addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalTo(snp.margins)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var intrinsicContentSize: CGSize {
        intrinsicSize ?? super.intrinsicContentSize
    }
}
