//
//  UIApplication+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2023/3/9.
//

import UIKit

public extension UIApplication {
    var activeScene: UIWindowScene? {
        connectedScenes.filter { $0.activationState == .foregroundActive }.first as? UIWindowScene
    }
    
    var keyWindows: [UIWindow] {
        if #available(iOS 15, *) {
            return UIApplication
                .shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        } else {
            return UIApplication
                .shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .filter { $0.isKeyWindow }
        }
    }
}
