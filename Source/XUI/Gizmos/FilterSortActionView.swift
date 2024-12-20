//
//  FilterSortActionView.swift
//  XUI
//
//  Created by xueqooy on 2023/9/5.
//

import UIKit

public class FilterSortActionView: UIView {
    public enum Action {
        case filter, sort
    }

    public var actionHandler: ((Action, UIView) -> Void)?

    public var filterBadgeNumber: Int = 0 {
        didSet {
            if filterBadgeNumber > 0 {
                filterBadgeView.isHidden = false
                filterBadgeView.value = "\(filterBadgeNumber)"
            } else {
                filterBadgeView.isHidden = true
            }
        }
    }

    public var sortBadgeNumber: Int = 0 {
        didSet {
            if sortBadgeNumber > 0 {
                sortBadgeView.isHidden = false
                sortBadgeView.value = "\(sortBadgeNumber)"
            } else {
                sortBadgeView.isHidden = true
            }
        }
    }

    private let buttonConfigurationTransformer = CustomButtonConfigurationTransformer { configuration, _ in
        configuration.foregroundColor = Colors.teal
        configuration.titleFont = Fonts.button2
    }

    private lazy var filterButton: Button = {
        var config = ButtonConfiguration()
        config.title = Strings.filter
        config.image = Icons.filter
        config.imagePadding = .XUI.spacing2
        return .init(configuration: config, configurationTransformer: buttonConfigurationTransformer)
    }()

    private lazy var sortButton: Button = {
        var config = ButtonConfiguration()
        config.title = Strings.sortBy
        config.image = Icons.sort
        config.imagePadding = 5
        return .init(configuration: config, configurationTransformer: buttonConfigurationTransformer)
    }()

    private var filterBadgeView = BadgeView()
    private var sortBadgeView = BadgeView()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        let separator = SeparatorView(orientation: .vertical)
        separator.heightAnchor.constraint(equalToConstant: .XUI.spacing6).isActive = true

        let stackView = HStackView(alignment: .center, spacing: .XUI.spacing2) {
            filterButton
            filterBadgeView
            separator
            sortButton
            sortBadgeView
        }

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        filterButton.touchUpInsideAction = { [weak self] in
            self?.actionHandler?(.filter, $0)
        }

        sortButton.touchUpInsideAction = { [weak self] in
            self?.actionHandler?(.sort, $0)
        }

        defer {
            filterBadgeNumber = 0
            sortBadgeNumber = 0
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
