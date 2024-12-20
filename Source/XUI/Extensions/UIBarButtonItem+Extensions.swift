//
//  UIBarButtonItem+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2023/9/11.
//

import UIKit

public extension UIBarButtonItem {
    static var flexibleSpace: UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }

    static func fixedSpace(width: CGFloat) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = width
        return barButtonItem
    }
}
