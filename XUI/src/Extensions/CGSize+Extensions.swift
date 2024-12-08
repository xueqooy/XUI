//
//  CGSize+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2023/8/1.
//

import UIKit

public extension CGSize {
    static let max = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    
    static func square(_ value: CGFloat) -> CGSize {
        CGSize(width: value, height: value)
    }
    
    func limit(to size: CGSize) -> CGSize {
        var result = self
        result.width = min(result.width, size.width)
        result.height = min(result.height, size.height)
        return result
    }
    
    func eraseNegative() -> CGSize {
        var result = self
        result.width = Swift.max(result.width, 0)
        result.height = Swift.max(result.height, 0)
        return result
    }
}
