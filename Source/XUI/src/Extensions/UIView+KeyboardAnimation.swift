//
//  UIView+KeyboardAnimation.swift
//  XUI
//
//  Created by xueqooy on 2023/8/1.
//

import UIKit

public extension UIView {
    static func animate(keyboardInfo: KeyboardInfo, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        let duration = keyboardInfo.animationDuration ?? 0
        let options = keyboardInfo.animationOptions ?? []
       
        animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, options], animations: animations, completion: completion)
    }
}

