//
//  ListToastCell.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/5.
//

import UIKit
import IGListKit

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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ListToastViewModel else {
            return
        }
        
        toastView.configuration = viewModel.configuration
    }
}
