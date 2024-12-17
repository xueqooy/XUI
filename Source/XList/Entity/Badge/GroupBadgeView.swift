//
//  GroupBadgeView.swift
//  XUI
//
//  Created by xueqooy on 2024/5/31.
//

import UIKit
import XUI

public class GroupBadgeView: BindingView {
    
    private static let verticalBarImage = generateImageWithMargins(image: Icons.verticalBar, margins: .init(top: 2, left: 14, bottom: 2, right: 2)).withRenderingMode(.alwaysTemplate)
    
    private static let roundSquareImage = generateImageWithMargins(image: Icons.roundSquare, margins: .init(uniformValue: 2)).withRenderingMode(.alwaysTemplate)
    
    
    private let colorImageView = UIImageView(contentMode: .scaleAspectFit)
        .settingSizeConstraint(.square(14))
    
    private let nameLabel = UILabel(textStyleConfiguration: .entityBadgeName)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
                
        let stackView = HStackView(spacing: .XUI.spacing1) {
            colorImageView
            
            nameLabel
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bindViewModel(_ viewModel: GroupEntity) {
        updateViewModel(viewModel)
        
        colorImageView.image = viewModel.parentEntityName != nil ? Self.verticalBarImage : Self.roundSquareImage
        colorImageView.tintColor = viewModel.color
        
        nameLabel.text = viewModel.name
    }
}

