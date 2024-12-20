//
//  ViewAllEntitiesCell.swift
//  XUI
//
//  Created by xueqooy on 2024/5/31.
//

import IGListKit
import UIKit
import XUI

class ViewAllEntitiesCell: UICollectionViewCell, ListCellSizeProviding, ListBindable {
    override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? .XUI.highlightAlpha : 1
        }
    }

    private let textLabel = UILabel()

    var cellSizeOptions: ListCellSizeOptions {
        [.compress, .cache, .configureCell]
    }

    private var height: CGFloat = 14

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindViewModel(_ viewModel: Any) {
        let viewModel = viewModel as! ViewAllEntitiesViewModel

        height = viewModel.height

        textLabel.richText = RTText(Strings.viewAll(viewModel.additionalCount), .foreground(Colors.teal), .font(Fonts.button3), .underline(.single))
    }

    var cellSize: CGSize {
        .init(width: .XUI.automaticDimension, height: height)
    }
}
