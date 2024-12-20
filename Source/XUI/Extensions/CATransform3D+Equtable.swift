//
//  CATransform3D+Equtable.swift
//  XUI
//
//  Created by xueqooy on 2024/5/8.
//

import Foundation
import QuartzCore

extension CATransform3D: @retroactive Equatable {
    public static func == (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
        return CATransform3DEqualToTransform(lhs, rhs)
    }
}
