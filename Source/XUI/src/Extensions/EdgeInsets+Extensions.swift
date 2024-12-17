//
//  UIEdgeInsets+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2023/8/1.
//

import UIKit

public extension UIEdgeInsets {
    
    var horizontal: CGFloat {
        left + right
    }
    
    var vertical: CGFloat {
        top + bottom
    }
    
    init(uniformValue value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}

public extension NSDirectionalEdgeInsets {
    
    var horizontal: CGFloat {
        leading + trailing
    }
    
    var vertical: CGFloat {
        top + bottom
    }
    
    init(uniformValue value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }
}
