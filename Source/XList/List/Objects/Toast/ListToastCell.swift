//
//  ListToastCell.swift
//  XUI
//
//  Created by xueqooy on 2024/1/5.
//

import IGListKit
import UIKit
import XUI

/// Toast used in Vertical List
class ListToastCell: UICollectionViewCell, ListBindable, ListCellSizeProviding {
    private let toastView = ToastView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(toastView)
        toastView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ListToastViewModel else {
            return
        }

        toastView.configuration = viewModel.configuration
    }
}
