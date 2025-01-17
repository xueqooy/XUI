//
//  CGPoint+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2023/8/1.
//

import UIKit

public extension CGPoint {
    func mid(to otherPoint: CGPoint) -> CGPoint {
        CGPoint(x: (x + otherPoint.x) / 2, y: (y + otherPoint.y) / 2)
    }

    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y
        return sqrt(dx * dx + dy * dy)
    }
}
