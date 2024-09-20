//
//  AvatarSize.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/19.
//

import Foundation

public enum AvatarSize: String {
    case unspecified
    case size14
    case size24
    case size30
    case size40
    case size56
}


extension AvatarSize {
    var intrinsicContentSize: CGSize {
        switch self {
        case .unspecified:
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        case .size14:
            return .square(14)
        case .size24:
            return .square(24)
        case .size30:
            return .square(30)
        case .size40:
            return .square(40)
        case .size56:
            return .square(56)
        }
    }
}
