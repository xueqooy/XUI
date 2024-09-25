//
//  Fonts.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/9/6.
//

import UIKit
import LLPUtils

/**
 Common colors
 */
@objcMembers
public class Fonts: NSObject {
    
    @objc(LLPFontWeight)
    public enum Weight: Int {
        case regular
        case bold
        
        fileprivate var fontName: String {
            switch self {
            case .regular:
                return "NotoSans-Regular"
    
            case .bold:
                return "NotoSans-Bold"
            }
        }
        
        fileprivate var nativeWeight: UIFont.Weight {
            switch self {
            case .regular:
                return .regular
      
            case .bold:
                return .bold
            }
        }
    }

    public static func font(ofSize size: CGFloat, weight: Fonts.Weight = .regular) -> UIFont {
        var font = UIFont(name: weight.fontName, size: size)
        if font == nil {
            Once.execute("Fonts_load_font_\(weight.fontName)") {
                LLPUIFramework.loadFont(named: weight.fontName)
            }
            font = UIFont(name: weight.fontName, size: size)
        }
        
        return font ?? UIFont.systemFont(ofSize: size, weight: weight.nativeWeight)        
    }
    
    // Definitions in https://www.figma.com/design/I8BC6rZsFONKRXToutZx2u/%F0%9F%96%A5%EF%B8%8F-Learner-Journey?node-id=3088-2595&node-type=canvas&t=1cAqm2eN2HNZLhoN-0
         
    /// 18 bold
    public static let h6 = font(ofSize: 20, weight: .bold)
        
    /// 18 regular
    public static let body1 = font(ofSize: 18, weight: .regular)
    /// 16 regular
    public static let body2 = font(ofSize: 16, weight: .regular)
    /// 14 regular
    public static let body3 = font(ofSize: 14, weight: .regular)
    /// 12 regular
    public static let body4 = font(ofSize: 12, weight: .regular)
    
    /// 18 bold
    public static let body1Bold = font(ofSize: 18, weight: .bold)
    /// 16 bold
    public static let body2Bold = font(ofSize: 16, weight: .bold)
    /// 14 bold
    public static let body3Bold = font(ofSize: 14, weight: .bold)
    /// 12 bold
    public static let body4Bold = font(ofSize: 12, weight: .bold)

    /// 14 bold
    public static let button1 = font(ofSize: 16, weight: .bold)
    /// 14 bold
    public static let button2 = font(ofSize: 14, weight: .bold)
    /// 12 bold
    public static let button3 = font(ofSize: 12, weight: .bold)
    
    /// 10 bold
    public static let caption = font(ofSize: 10, weight: .bold)
    
}
