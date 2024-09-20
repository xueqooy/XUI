//
//  EntityBadgeCell.swift
//  LLPUI
//
//  Created by xueqooy on 2024/7/1.
//

import UIKit

class EntityBadgeCell<View: BindingView>: ListBindingCell<View>, ListCellSizeProviding {
    
    override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? .LLPUI.highlightAlpha : 1
        }
    }
    
    var cellSizeOptions: ListCellSizeOptions {
        [.configureCell, .cache, .compress]
    }
    
    var cellSize: CGSize {
        .init(width: .LLPUI.automaticDimension, height: 14)
    }
}


protocol EntityBadgeCancellable {
    var cancelHandler: (() -> Void)? { set get }
}


class CancellableEntityBadgeCell<View: BindingView>: EntityBadgeCell<View>, EntityBadgeCancellable {
    
    override var viewInset: UIEdgeInsets {
        .init(top: .LLPUI.spacing1, left: .LLPUI.spacing2, bottom: .LLPUI.spacing1, right: .LLPUI.spacing7)
    }
    
    override var cellSize: CGSize {
        .init(width: .LLPUI.automaticDimension, height: 22)
    }
    
    var cancelHandler: (() -> Void)?
    
    private lazy var cancelButton = Button(image: Icons.cancel, imageSize: .square(14), foregroundColor: Colors.vibrantTeal) { [weak self] _ in
        self?.cancelHandler?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView = BackgroundView(configuration: .init(fillColor: Colors.lightTeal, cornerStyle: .capsule))

        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(CGFloat.LLPUI.spacing2)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
