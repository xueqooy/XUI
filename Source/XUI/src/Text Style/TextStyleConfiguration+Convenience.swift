//
//  TextStyleConfiguration+Convenience.swift
//  XUI
//
//  Created by xueqooy on 2024/1/4.
//

import Foundation

public extension TextStyleConfiguration {
    
    
    static let label = TextStyleConfiguration(textColor: Colors.title, font: Fonts.body4Bold, textAlignment: .natural)
    
    static let textInput = TextStyleConfiguration(textColor: Colors.title, font: Fonts.body4, textAlignment: .left)
    
    static let placeholder = TextStyleConfiguration(textColor: Colors.disabledText, font: Fonts.body4, textAlignment: .left)
   
    static let personaTitle = TextStyleConfiguration(textColor: Colors.teal, font: Fonts.body2Bold, textAlignment: .left)
    
    static let personaSubtitle = TextStyleConfiguration(textColor: Colors.bodyText1, font: Fonts.body2, textAlignment: .left)
    
    static let hudText = TextStyleConfiguration(textColor: Colors.title, font: Fonts.body1Bold, textAlignment: .center)
    
    static let entityBadgeName = TextStyleConfiguration(textColor: Colors.bodyText1, font: Fonts.body3)
    
    static let entityListName = TextStyleConfiguration(textColor: Colors.title, font: Fonts.body1Bold)
}
