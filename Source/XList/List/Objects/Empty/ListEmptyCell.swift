//
//  ListEmptyCell.swift
//  XUI
//
//  Created by xueqooy on 2024/1/5.
//

import IGListKit
import UIKit
import XUI

class ListEmptyCell: UICollectionViewCell, ListBindable, ListCellSizeProviding {
    private let emptyView = EmptyView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        emptyView.startLoadingIfNeeded()
    }

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ListEmptyViewModel else {
            return
        }

        emptyView.configuration = viewModel.configuration
    }
}
