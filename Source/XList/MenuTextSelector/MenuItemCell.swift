//
//  MenuItemCell.swift
//  XUI
//
//  Created by xueqooy on 2024/4/29.
//

import UIKit
import XUI

class MenuItemCell: UICollectionViewCell {
    
    var title: String? {
        didSet {
            checkmark.title = title
        }
    }
    
    override var isSelected: Bool {
        didSet {
            checkmark.isSelected = isSelected
            selectedView.isHidden = !isSelected
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                if !isSelected {
                    selectedView.isHidden = false
                    selectedView.alpha = 0.5
                }
            } else {
                if !isSelected {
                    selectedView.isHidden = true
                    selectedView.alpha = 1.0
                }
            }
        }
    }
    
    private let selectedView = BackgroundView(configuration: .init(fillColor: Colors.background1, cornerStyle: .fixed(.XUI.smallCornerRadius)))
        
    private let checkmark: OptionControl = {
        let checkmark = OptionControl(style: .checkmark, titlePlacement: .leading)
        checkmark.textStyleConfiguration = .textInput
        checkmark.isUserInteractionEnabled = false
        return checkmark
    }()
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(selectedView)
        selectedView.isHidden = true
        selectedView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: .XUI.spacing2, bottom: 0, right: .XUI.spacing2))
        }
        
        contentView.addSubview(checkmark)
        checkmark.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: .XUI.spacing2, left: .XUI.spacing4, bottom: .XUI.spacing2, right: .XUI.spacing4))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MenuItemCell: ListCellSizeProviding {
}
