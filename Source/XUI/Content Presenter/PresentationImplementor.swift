//
//  PresentationImplementor.swift
//  XUI
//
//  Created by xueqooy on 2023/12/29.
//

import Foundation

class PresentationImplementor {
    unowned let presenter: ContentPresenter

    init(presenter: ContentPresenter) {
        self.presenter = presenter
    }

    func activate(completion _: (() -> Void)? = nil) {}

    func deactivate(completion _: (() -> Void)? = nil) {}
}
