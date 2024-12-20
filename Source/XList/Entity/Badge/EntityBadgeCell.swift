//
//  EntityBadgeCell.swift
//  XUI
//
//  Created by xueqooy on 2024/7/1.
//

import UIKit
import XUI

class EntityBadgeCell<View: BindingView>: ListBindingCell<View>, ListCellSizeProviding {
    override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? .XUI.highlightAlpha : 1
        }
    }

    var cellSizeOptions: ListCellSizeOptions {
        [.configureCell, .cache, .compress]
    }

    var cellSize: CGSize {
        .init(width: .XUI.automaticDimension, height: 14)
    }
}

protocol EntityBadgeCancellable {
    var cancelHandler: (() -> Void)? { set get }
}

class CancellableEntityBadgeCell<View: BindingView>: EntityBadgeCell<View>, EntityBadgeCancellable {
    override var viewInset: UIEdgeInsets {
        .init(top: .XUI.spacing1, left: .XUI.spacing2, bottom: .XUI.spacing1, right: .XUI.spacing7)
    }

    override var cellSize: CGSize {
        .init(width: .XUI.automaticDimension, height: 22)
    }

    var cancelHandler: (() -> Void)?

    private lazy var cancelButton = Button(image: Icons.xmarkSmall, imageSize: .square(10), foregroundColor: Colors.teal) { [weak self] _ in
        self?.cancelHandler?()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundView = BackgroundView(configuration: .init(fillColor: Colors.extraLightTeal, cornerStyle: .capsule))

        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(CGFloat.XUI.spacing2)
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
