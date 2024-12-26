//
//  PDFFullscreenWindow.swift
//  XUI
//
//  Created by xueqooy on 2024/12/26.
//

import UIKit

class PDFFullscreenWindow: UIWindow {
    let viewController = PDFFullscreenViewController()

    init() {
        if let windowScene = UIApplication.shared.activeScene {
            let keywindow = windowScene.windows.first { $0.isKeyWindow }

            super.init(frame: keywindow?.bounds ?? UIScreen.main.bounds)
            self.windowScene = windowScene

        } else {
            super.init(frame: UIApplication.shared.keyWindows.first?.bounds ?? UIScreen.main.bounds)
        }

        viewController.loadViewIfNeeded()

        rootViewController = viewController
        windowLevel = .statusBar - 1
        isHidden = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
