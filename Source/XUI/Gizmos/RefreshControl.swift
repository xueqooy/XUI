//
//  RefreshControl.swift
//  XUI
//
//  Created by xueqooy on 2023/9/11.
//

import UIKit

public class RefreshControl: UIRefreshControl {
    override public convenience init() {
        self.init(frame: .zero)
    }

    override public init(frame _: CGRect) {
        super.init(frame: .zero)

        initialize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    private func initialize() {
        tintColor = Colors.teal
    }
}
