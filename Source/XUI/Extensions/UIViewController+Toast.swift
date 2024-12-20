//
//  UIViewController+Toast.swift
//  XUI
//
//  Created by xueqooy on 2023/8/10.
//

import UIKit

public extension UIViewController {
    func showToast(style: ToastView.Style, _ message: String = "", richMessage: RichText? = nil) {
        ToastView(style: style, message: message, richMessage: richMessage).show(from: self) { view in
            view.hide(after: .XUI.autoHideDelay)
        }
    }

    func showToast(with configuration: ToastView.Configuration) {
        ToastView(configuration: configuration).show(from: self) { view in
            view.hide(after: .XUI.autoHideDelay)
        }
    }
}
