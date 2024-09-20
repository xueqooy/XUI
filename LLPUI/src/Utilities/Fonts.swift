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
public struct Fonts {
    
    public enum Weight: Int {
        case regular
        case medium
        case semibold
        case bold
        
        fileprivate var fontName: String {
            switch self {
            case .regular:
                return "Poppins-Regular"
            case .medium:
                return "Poppins-Medium"
            case .semibold:
                return "Poppins-SemiBold"
            case .bold:
                return "Poppins-Bold"
            }
        }
        
        fileprivate var nativeWeight: UIFont.Weight {
            switch self {
            case .regular:
                return .regular
            case .medium:
                return .medium
            case .semibold:
                return .semibold
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
         
    /// 28 semibold
    public static let h1 = font(ofSize: 28, weight: .semibold)
    /// 24 semibold
    public static let h2 = font(ofSize: 24, weight: .semibold)
    /// 20 semibold
    public static let h3 = font(ofSize: 20, weight: .semibold)
    /// 18 semibold
    public static let h4 = font(ofSize: 18, weight: .semibold)
    
    /// 16 semibold
    public static let title1 = font(ofSize: 16, weight: .semibold)
    /// 14 semibold
    public static let title2 = font(ofSize: 14, weight: .semibold)
    /// 12 semibold
    public static let title3 = font(ofSize: 12, weight: .semibold)
    
    /// 14 medium
    public static let subtitle1 = font(ofSize: 14, weight: .medium)
    /// 12 medium
    public static let subtitle2 = font(ofSize: 12, weight: .medium)
    /// 10 medium
    public static let subtitle3 = font(ofSize: 10, weight: .medium)
    
    /// 14 medium
    public static let body1 = font(ofSize: 14, weight: .medium)
    /// 12 medium
    public static let body2 = font(ofSize: 12, weight: .medium)
    /// 10 medium
    public static let body3 = font(ofSize: 10, weight: .medium)
    
    /// 14 semibold
    public static let button1 = font(ofSize: 14, weight: .semibold)
    /// 12 semibold
    public static let button2 = font(ofSize: 12, weight: .semibold)
    /// 10 semibold
    public static let button3 = font(ofSize: 10, weight: .semibold)
    
    /// 10 semibold
    public static let caption = font(ofSize: 10, weight: .semibold)
    
}
