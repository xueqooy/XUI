//
//  UIFont+Extensions.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/9/21.
//

import UIKit

public extension UIFont {
    var deviceLineHeight: CGFloat { return lineHeight.flatInPixel() }
    var deviceLineHeightWithLeading: CGFloat { return (lineHeight + max(0, leading)).flatInPixel() }
}
