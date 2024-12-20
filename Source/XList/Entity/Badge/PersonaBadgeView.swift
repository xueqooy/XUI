//
//  PersonaBadgeView.swift
//  XUI
//
//  Created by xueqooy on 2024/5/31.
//

import UIKit
import XUI

public class PersonaBadgeView: BindingView {
    private let avatarView = AvatarView(size: .size14)

    private let nameLabel = UILabel(textStyleConfiguration: .entityBadgeName)

    override public init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = HStackView(spacing: .XUI.spacing1) {
            avatarView

            nameLabel
        }

        addSubview(stackView)
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
