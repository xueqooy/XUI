//
//  EntityListGroupCell.swift
//  XUI
//
//  Created by xueqooy on 2024/5/31.
//

import UIKit

public class EntityListGroupCell: UICollectionViewCell, Bindable {
    
    public override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? .XUI.highlightAlpha : 1
        }
    }
    
    public override var isSelected: Bool {
        didSet {
            checkmarkImageView.isHidden = !isSelected || !displayCheckmarkWhenSelected
        }
    }
    
    public var displayCheckmarkWhenSelected: Bool = false {
        didSet {
            checkmarkImageView.isHidden = !isSelected || !displayCheckmarkWhenSelected
        }
    }
    
    
    private static let verticalBarImage = generateImageWithMargins(image: Icons.verticalBar, margins: .init(top: 0, left: 12, bottom: 0, right: 0)).withRenderingMode(.alwaysTemplate)
    
    private let colorImageView = UIImageView(contentMode: .scaleAspectFit)
        .settingSizeConstraint(.square(22))
    
    private let parentEntityNameLabel = UILabel(textStyleConfiguration: .entityBadgeName)
    
    private let nameLabel = UILabel(textStyleConfiguration: .entityListName)
    
    private let checkmarkImageView = UIImageView(image: Icons.checkmark, tintColor: Colors.teal)
        .settingHidden(true)
        .settingContentCompressionResistanceAndHuggingPriority(.required)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = HStackView(alignment: .center, spacing: .XUI.spacing3) {
            colorImageView
            
            VStackView(spacing: 2) {
                parentEntityNameLabel
                
                nameLabel
            }
            
            checkmarkImageView
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bindViewModel(_ viewModel: GroupEntity) {
        updateViewModel(viewModel)
        
        colorImageView.image = viewModel.parentEntityName != nil ? Self.verticalBarImage : Icons.roundSquare
        colorImageView.tintColor = viewModel.color
        
        parentEntityNameLabel.text = viewModel.parentEntityName
        
        nameLabel.text = viewModel.name
    }
}
