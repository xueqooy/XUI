//
//  UILabel+Convenience.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit

public extension UILabel {
    
    convenience init(text: String? = nil, richText: RichText? = nil, textColor: UIColor? = nil, font: UIFont? = nil, textAlignment: NSTextAlignment = .natural, numberOfLines: Int = 1) {
        self.init()
        
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        
        if let richText {
            self.richText = richText
        } else {
            self.text = text
        }
    }
    
    convenience init(text: String? = nil, richText: RichText? = nil, textStyleConfiguration: TextStyleConfiguration, numberOfLines: Int = 1) {
        self.init()
        
        self.textStyleConfiguration = textStyleConfiguration
        self.numberOfLines = numberOfLines
        
        if let richText {
            self.richText = richText
        } else {
            self.text = text
        }
    }
    
}
