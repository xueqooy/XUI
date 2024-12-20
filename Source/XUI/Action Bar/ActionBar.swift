//
//  ActionBar.swift
//  XUI
//
//  Created by xueqooy on 2024/3/28.
//

import UIKit

public class ActionBar: UIView {
    public enum Alignment {
        case center
        case leading
    }

    public var items: [ActionBarItem] = [] {
        didSet {
            setupItems()
        }
    }

    public let alignment: Alignment

    private let debug: Bool

    private let buttonViewStack = HStackView()

    public init(alignment: Alignment = .center, items: [ActionBarItem] = [], debug: Bool = false) {
        self.alignment = alignment
        self.debug = debug

        super.init(frame: .zero)

        initialize()

        defer {
            self.items = items
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        addSubview(buttonViewStack)

        switch alignment {
        case .center:
            buttonViewStack.distribution = .fillEqually

            buttonViewStack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

        case .leading:
            buttonViewStack.distribution = .fill
            buttonViewStack.spacing = .XUI.spacing3

            buttonViewStack.snp.makeConstraints { make in
                make.top.leading.bottom.equalToSuperview()
                make.trailing.lessThanOrEqualToSuperview()
            }
        }
    }

    private func setupItems() {
        buttonViewStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for element in items {
            let buttonView = ActionBarButtonView(alignment: alignment, item: element, debug: debug)
            buttonViewStack.addArrangedSubview(buttonView)
        }
    }
}
