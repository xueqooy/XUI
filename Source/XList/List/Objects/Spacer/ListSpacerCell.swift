//
//  ListSpacerCell.swift
//  XUI
//
//  Created by xueqooy on 2023/10/25.
//

import IGListKit
import UIKit

public class ListSpacerCell: UICollectionViewCell, ListBindable {
    private var spacing: CGFloat = 0

    public func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ListSpacer else {
            return
        }

        spacing = viewModel.spacing
    }
}

extension ListSpacerCell: ListCellSizeProviding {
    public var cellSize: CGSize {
        layoutContext.stretchedSize(withScrollAxisExtent: spacing)
    }

    public var cellSizeOptions: ListCellSizeOptions {
        .configureCell
    }
}
