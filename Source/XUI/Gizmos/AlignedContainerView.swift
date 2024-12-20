//
//  AlignedContainerView.swift
//  XUI
//
//  Created by xueqooy on 2024/6/19.
//

import UIKit

public class AlignedContainerView: UIView {
    public enum Alignment: Equatable {
        case fill, center
        case leading, trailing, centerHorizontally // Horizontal Axis
        case top, bottom, centerVertically // Vertical Axis
    }

    public var alignment: Alignment {
        didSet {
            if alignment == oldValue {
                return
            }

            updateViewConstrants()
        }
    }

    private weak var view: UIView?

    public init(_ view: UIView, alignment: Alignment) {
        self.alignment = alignment
        self.view = view

        super.init(frame: .zero)

        addSubview(view)
        updateViewConstrants()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateViewConstrants() {
        guard let view else { return }

        view.snp.remakeConstraints { make in
            switch alignment {
            case .fill:
                make.edges.equalToSuperview()

            case .center:
                make.width.lessThanOrEqualToSuperview()
                make.height.lessThanOrEqualToSuperview()
                make.center.equalToSuperview()

            case .leading:
                make.top.bottom.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
                make.leading.equalToSuperview()

            case .trailing:
                make.top.bottom.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
                make.trailing.equalToSuperview()

            case .centerHorizontally:
                make.top.bottom.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
                make.centerX.equalToSuperview()

            case .top:
                make.leading.trailing.equalToSuperview()
                make.height.lessThanOrEqualToSuperview()
                make.top.equalToSuperview()

            case .bottom:
                make.leading.trailing.equalToSuperview()
                make.height.lessThanOrEqualToSuperview()
                make.bottom.equalToSuperview()

            case .centerVertically:
                make.leading.trailing.equalToSuperview()
                make.height.lessThanOrEqualToSuperview()
                make.centerY.equalToSuperview()
            }
        }
    }
}
