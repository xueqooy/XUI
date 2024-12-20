//
//  EntityListPersonaCell.swift
//  XUI
//
//  Created by xueqooy on 2024/5/31.
//

import UIKit
import XUI

public class EntityListPersonaCell: UICollectionViewCell, Bindable {
    override public var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? .XUI.highlightAlpha : 1
        }
    }

    override public var isSelected: Bool {
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

    private let checkmarkImageView = UIImageView(image: Icons.checkmark, tintColor: Colors.teal)
        .settingHidden(true)
        .settingContentCompressionResistanceAndHuggingPriority(.required)

    override public init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = HStackView(alignment: .center, spacing: .XUI.spacing3) {
            avatarView

            nameLabel

            checkmarkImageView
        }

        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func bindViewModel(_ viewModel: PersonaEntity) {
        updateViewModel(viewModel)

        avatarView.urlConfiguration = viewModel.avatarURLConfiguration

        nameLabel.text = viewModel.name
    }
}
