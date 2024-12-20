//
//  ActionBarButtonView.swift
//  XUI
//
//  Created by xueqooy on 2024/3/28.
//

import Combine
import UIKit
import XKit

class ActionBarButtonView: UIView {
    private(set) lazy var button = Button(configurationTransformer: ActionBarButtonConfigurationTransformer(debug: debug))

    let alignment: ActionBar.Alignment
    let item: ActionBarItem

    private let debug: Bool
    private var cancellable: AnyCancellable?

    init(alignment: ActionBar.Alignment, item: ActionBarItem, debug: Bool = false) {
        self.alignment = alignment
        self.item = item
        self.debug = debug

        super.init(frame: .zero)

        initialize()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        addSubview(button)

        switch alignment {
        case .center:
            button.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        case .leading:
            button.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }

        update()

        cancellable = item.stateDidChange
            .sink { [weak self] in
                self?.update()
            }

        button.touchUpInsideAction = { [weak self] in
            guard let item = self?.item else { return }

            self?.item.handler(item, $0)
        }
    }

    private func update() {
        button.update {
            $0.title = item.title
            $0.image = item.image
            $0.titleColor = item.titleColor
        }

        isHidden = item.isHidden
    }
}
