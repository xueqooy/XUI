//
//  UIRectCorner+Extensions.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/1.
//

import UIKit

public extension UIRectCorner {
    func asCACornerMask() -> CACornerMask {
        var corners: CACornerMask = []
        if self.contains(.topLeft) {
            corners.insert(.layerMinXMinYCorner)
        }
        if self.contains(.topRight) {
            corners.insert(.layerMaxXMinYCorner)
        }
        if self.contains(.bottomLeft) {
            corners.insert(.layerMinXMaxYCorner)
        }
        if self.contains(.bottomRight) {
            corners.insert(.layerMaxXMaxYCorner)
        }
        return corners
    }
}

public extension CACornerMask {
    func asUIRectCorner() -> UIRectCorner {
        var corners: UIRectCorner = []
        if self.contains(.layerMinXMinYCorner) {
            corners.insert(.topLeft)
        }
        if self.contains(.layerMaxXMinYCorner) {
            corners.insert(.topRight)
        }
        if self.contains(.layerMinXMaxYCorner) {
            corners.insert(.bottomLeft)
        }
        if self.contains(.layerMaxXMaxYCorner) {
            corners.insert(.bottomRight)
        }
        return corners
    }
}
