//
//  NSShadow+Convenience.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/18.
//

import UIKit

public extension NSShadow {
    convenience init(offset: CGSize, radius: CGFloat, color: UIColor? = nil) {
        self.init()
        self.shadowOffset = offset
        self.shadowBlurRadius = radius
        self.shadowColor = color
    }
}
