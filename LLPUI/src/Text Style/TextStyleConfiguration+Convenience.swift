//
//  TextStyleConfiguration+Convenience.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/4.
//

import Foundation

public extension TextStyleConfiguration {
    
    static let label = TextStyleConfiguration(textColor: Colors.title, font: Fonts.subtitle2, textAlignment: .natural)
    
    static let textInput = TextStyleConfiguration(textColor: Colors.bodyText1, font: Fonts.body1, textAlignment: .left)
    
    static let placeholder = TextStyleConfiguration(textColor: Colors.bodyText2, font: Fonts.body1, textAlignment: .left)
   
    static let personaTitle = TextStyleConfiguration(textColor: Colors.vibrantTeal, font: Fonts.title2, textAlignment: .left)
    
    static let personaSubtitle = TextStyleConfiguration(textColor: Colors.bodyText2, font: Fonts.body2, textAlignment: .left)
    
    static let hudText = TextStyleConfiguration(textColor: Colors.title, font: Fonts.title1, textAlignment: .center)
    
    static let entityBadgeName = TextStyleConfiguration(textColor: Colors.bodyText1, font: Fonts.body3)
    
    static let entityListName = TextStyleConfiguration(textColor: Colors.title, font: Fonts.subtitle1)
}
