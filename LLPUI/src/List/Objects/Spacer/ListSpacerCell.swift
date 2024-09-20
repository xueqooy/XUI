//
//  ListSpacerCell.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/25.
//

import UIKit
import IGListKit

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