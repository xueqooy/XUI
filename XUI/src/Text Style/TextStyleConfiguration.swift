//
//  TextStyleConfiguration.swift
//  XKit
//
//  Created by xueqooy on 2023/3/8.
//

import UIKit
import XKit

/// Convenient unified configuration of text style
public struct TextStyleConfiguration: Equatable, Then {
    public var textColor: UIColor?
    public var font: UIFont?
    public var textAlignment: NSTextAlignment = .natural
    
    public init(textColor: UIColor? = nil, font: UIFont? = nil, textAlignment: NSTextAlignment = .natural) {
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
    }
}


public protocol TextStyleConfigurable {
    var textStyleConfiguration: TextStyleConfiguration { set get }
}

