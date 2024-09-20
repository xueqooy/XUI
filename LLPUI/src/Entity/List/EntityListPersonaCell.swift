//
//  EntityListPersonaCell.swift
//  LLPUI
//
//  Created by xueqooy on 2024/5/31.
//

import UIKit

public class EntityListPersonaCell: UICollectionViewCell, Bindable {
    
    public override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? .LLPUI.highlightAlpha : 1
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
    
    
    private let avatarView = AvatarView(size: .size24)
    
    private let nameLabel = UILabel(textStyleConfiguration: .entityListName)
    
    private let checkmarkImageView = UIImageView(image: Icons.checkmark, tintColor: Colors.vibrantTeal)
        .settingHidden(true)
        .settingContentCompressionResistanceAndHuggingPriority(.required)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = HStackView(alignment: .center, spacing: .LLPUI.spacing3) {
            avatarView
            
            nameLabel
            
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
    
    public func bindViewModel(_ viewModel: PersonaEntity) {
        updateViewModel(viewModel)
        
        avatarView.urlConfiguration = viewModel.avatarURLConfiguration
        
        nameLabel.text = viewModel.name
    }
}
