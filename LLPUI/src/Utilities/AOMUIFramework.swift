//
//  LLPUIFramework.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/9/14.
//

import UIKit
import LLPUtils
import CoreText.CTFontManager

public class LLPUIFramework {
    
    static var bundle: Bundle { return Bundle(for: self) }

    public static let resourceBundle: Bundle = {
        guard let url = bundle.resourceURL?.appendingPathComponent("LLPUI_RESOURCE.bundle", isDirectory: true),
              let bundle = Bundle(url: url) else {
            preconditionFailure("LLPUI resource bundle is not found")
        }
        return bundle
    }()

    
    public static func color(named name: String, namespace: String? = nil) -> UIColor {
        let fullname = (namespace != nil ? (namespace! + "/") : "") + name
        guard let color = UIColor(named: fullname, in: Self.resourceBundle, compatibleWith: nil) else {
            Logs.error("Missing color named \(fullname)", tag: "LLPUI")
            
            return .clear
        }
        
        return color
    }
    
    public static func image(named name: String) -> UIImage {
        guard let image = UIImage(named: name, in: Self.resourceBundle, compatibleWith: nil) else {
            Logs.error("Missing image named \(name)", tag: "LLPUI")
            return .init()
        }
 
        return image
    }
    
    @discardableResult
    static func loadFont(named name: String) -> Bool {
        guard let url = resourceBundle.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts"), let fontData = try? Data(contentsOf: url) else {
            return false
        }

        guard let provider = CGDataProvider(data: fontData as CFData), let font = CGFont(provider) else {
            return false
        }
        
        if !CTFontManagerRegisterGraphicsFont(font, nil) {
            Logs.error("load font \(name) failed", tag: "LLPUI")
            return false
        } else {
            return true
        }
    }
}
