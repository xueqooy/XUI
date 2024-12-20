//
//  MessageInputBarHostingView.swift
//  XUI
//
//  Created by xueqooy on 2024/3/11.
//

import UIKit

public class MessageInputBarHostingView: UIView {
    override public var safeAreaLayoutGuide: UILayoutGuide {
        safeLayoutGuideWithInputBar
    }

    private var originalSafeLayoutGuide: UILayoutGuide {
        super.safeAreaLayoutGuide
    }

    private lazy var safeLayoutGuideWithInputBar: UILayoutGuide = {
        let layoutGuide = UILayoutGuide()

        addLayoutGuide(layoutGuide)
        layoutGuide.snp.makeConstraints { make in
            make.top.left.right.equalTo(originalSafeLayoutGuide)
            make.bottom.equalTo(inputBar.snp.top)
        }

        return layoutGuide
    }()

    private let inputBar: MessageInputBar

    public init(inputBar: MessageInputBar) {
        self.inputBar = inputBar

        super.init(frame: .zero)

        backgroundColor = .white

        addSubview(inputBar)
        inputBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(dockedKeyboardLayoutGuideIgnoringSafeArea.snp.top)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        bringSubviewToFront(inputBar)
    }

    override public func becomeFirstResponder() -> Bool {
        inputBar.inputField.becomeFirstResponder()
    }

    override public func resignFirstResponder() -> Bool {
        inputBar.inputField.resignFirstResponder()
    }
}
