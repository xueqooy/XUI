//
//  CGFloat+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2023/8/1.
//

import UIKit

let screenScale = UIScreen.main.scale

public extension CGFloat {
    func removeFloatMin() -> CGFloat {
        self == .leastNormalMagnitude ? 0 : self
    }
    
    func flatSpecificScale(_ scale: CGFloat) -> CGFloat {
        let scale = scale == 0 ? screenScale : scale
        return ceil(removeFloatMin() * scale) / scale
    }
    
    func flatInPixel() -> CGFloat {
        flatSpecificScale(0)
    }
    
    func floorInPixel() -> CGFloat {
        floor(removeFloatMin() * screenScale) / screenScale
    }
}
