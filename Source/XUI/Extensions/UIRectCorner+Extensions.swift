//
//  UIRectCorner+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2023/8/1.
//

import UIKit

public extension UIRectCorner {
    func asCACornerMask() -> CACornerMask {
        var corners: CACornerMask = []
        if contains(.topLeft) {
            corners.insert(.layerMinXMinYCorner)
        }
        if contains(.topRight) {
            corners.insert(.layerMaxXMinYCorner)
        }
        if contains(.bottomLeft) {
            corners.insert(.layerMinXMaxYCorner)
        }
        if contains(.bottomRight) {
            corners.insert(.layerMaxXMaxYCorner)
        }
        return corners
    }
}

public extension CACornerMask {
    func asUIRectCorner() -> UIRectCorner {
        var corners: UIRectCorner = []
        if contains(.layerMinXMinYCorner) {
            corners.insert(.topLeft)
        }
        if contains(.layerMaxXMinYCorner) {
            corners.insert(.topRight)
        }
        if contains(.layerMinXMaxYCorner) {
            corners.insert(.bottomLeft)
        }
        if contains(.layerMaxXMaxYCorner) {
            corners.insert(.bottomRight)
        }
        return corners
    }
}
