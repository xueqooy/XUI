//
//  DropdownMenuCell.swift
//  XUI
//
//  Created by xueqooy on 2024/5/7.
//

import Combine
import UIKit
import XKit
import XUI

class DropdownMenuCell: UICollectionViewCell {
    static let titleLines = 1

    private let titleLabel = InsetLabel(numberOfLines: DropdownMenuCell.titleLines).then {
        $0.adjustsFontSizeToFitWidth = true
    }

    private var cancellables = Set<AnyCancellable>()

    private let highlightedView = BackgroundView(configuration: .init(fillColor: Colors.background1))
        .settingHidden(true)

    override var isHighlighted: Bool {
        didSet {
            highlightedView.isHidden = !isHighlighted
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(highlightedView)
        highlightedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        cancellables.removeAll()
    }

    func update(withAction action: DropdownMenu.Action, style: DropdownMenu.Preference.Style) {
        highlightedView.configuration.cornerStyle = .fixed(style.actionHighlightCornerRadius)

        titleLabel.inset = .nondirectional(top: 0, left: style.actionTitleHorizontalInset, bottom: 0, right: style.actionTitleHorizontalInset)
        titleLabel.font = style.actionTitleFont

        action.$title.didChange
            .sink { [weak self] in
                guard let self else { return }

                self.titleLabel.text = $0
            }
            .store(in: &cancellables)

        action.$state.didChange
            .sink { [weak self] in
                guard let self else { return }

                switch $0 {
                case .on:
                    self.titleLabel.textColor = Colors.teal

                case .off:
                    self.titleLabel.textColor = Colors.title
                }
            }
            .store(in: &cancellables)
    }
}
