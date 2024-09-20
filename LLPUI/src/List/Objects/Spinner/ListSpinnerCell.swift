//
//  ListSpinnerCell.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/10.
//

import UIKit
import IGListKit

class ListSpinnerCell: UICollectionViewCell, ListBindable {
    
    private var extent: CGFloat = 0
    
    private let activityIndicator = ActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ListSpinner else {
            return
        }
        
        extent = viewModel.extent
    }
}

extension ListSpinnerCell: ListCellSizeProviding {
    
    public var cellSize: CGSize {
        layoutContext.stretchedSize(withScrollAxisExtent: extent)
    }
    
    public var cellSizeOptions: ListCellSizeOptions {
        .configureCell
    }
}
