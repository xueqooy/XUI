//
//  UIColor+Extensions.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/9/20.
//

import UIKit

public struct ColorValue: Hashable {
    /// Creates a color value instance with  4-channel hex value
    ///
    /// For example: `0xFF0000FF` represents red.
    public init(rgba: UInt32) {
        hexValue = rgba
    }

    /// Creates a color value instance with  3-channel hex value
    ///
    /// For example: `0xFF0000` represents red.
    public init(rgb: UInt32) {
        hexValue = rgb << 8 | 0xFF
    }

    /// Creates a color value instance with 8-bit rgb channel value and floating alpha channel.
    ///
    /// For example: `(r: 0xFF, g: 0, b, 0, a: 1)` represents red.
    public static func with8Bit(r: UInt8, g: UInt8, b: UInt8, a: CGFloat) -> ColorValue {
        let rgba = (UInt32(r) << 24) |
            (UInt32(g) << 16) |
            (UInt32(b) << 8) |
            min(UInt32(a * 255.0), 0xFF)
        return .init(rgba: rgba)
    }

    /// Creates a color value instance with floating rgb channel value and floating alpha channel.
    ///
    /// For example: `(r: 1, g: 0, b: 0, a: 1)` represents red.
    public static func withFloating(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> ColorValue {
        let rgba = (min(UInt32(r * 255.0), 0xFF) << 24) |
            (min(UInt32(g * 255.0), 0xFF) << 16) |
            (min(UInt32(b * 255.0), 0xFF) << 8) |
            min(UInt32(a * 255.0), 0xFF)
        return .init(rgba: rgba)
    }

    /// Creates a color value instance with  hex value
    ///
    /// For example: `"#FF0000FF"` or  `#FF0000` represents red.
    public static func withHexString(_ hexString: String) -> ColorValue? {
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(after: hexString.startIndex)
        }
        var value: UInt64 = 0
        if scanner.scanHexInt64(&value) {
            if hexString.count > 7 {
                return .init(rgba: UInt32(value))
            } else {
                return .init(rgb: UInt32(value))
            }
        } else {
            return nil
        }
    }

    var r: CGFloat { CGFloat((hexValue & 0xFF00_0000) >> 24) / 255.0 }
    var g: CGFloat { CGFloat((hexValue & 0x00FF_0000) >> 16) / 255.0 }
    var b: CGFloat { CGFloat((hexValue & 0x0000_FF00) >> 8) / 255.0 }
    var a: CGFloat { CGFloat(hexValue & 0x0000_00FF) / 255.0 }

    // Value is stored in RGBA format.
    private let hexValue: UInt32
}

public extension UIColor {
    /// Creates a UIColor from a `ColorValue` instance.
    ///
    /// - Parameter colorValue: Color value to use to initialize this color.
    convenience init(colorValue: ColorValue) {
        self.init(
            red: colorValue.r,
            green: colorValue.g,
            blue: colorValue.b,
            alpha: colorValue.a
        )
    }

    convenience init?(hexString: String) {
        if let colorValue = ColorValue.withHexString(hexString) {
            self.init(colorValue: colorValue)
        } else {
            return nil
        }
    }

    var colorValue: ColorValue? {
        var redValue: CGFloat = 1.0
        var greenValue: CGFloat = 1.0
        var blueValue: CGFloat = 1.0
        var alphaValue: CGFloat = 1.0
        if getRed(&redValue, green: &greenValue, blue: &blueValue, alpha: &alphaValue) {
            let colorValue = ColorValue.withFloating(r: redValue, g: greenValue, b: blueValue, a: alphaValue)
            return colorValue
        } else {
            return nil
        }
    }

    var isDark: Bool {
        var redValue: CGFloat = 1.0
        var greenValue: CGFloat = 1.0
        var blueValue: CGFloat = 1.0
        if getRed(&redValue, green: &greenValue, blue: &blueValue, alpha: nil) {
            let referenceValue = 0.411
            let colorDelta = ((redValue * 0.299) + (greenValue * 0.587) + (blueValue * 0.114))

            return 1.0 - colorDelta > referenceValue
        } else {
            return true
        }
    }

    func withMultiplicativeAlpha(_ alpha: CGFloat) -> UIColor {
        var originalAlpha: CGFloat = 0
        if !getRed(nil, green: nil, blue: nil, alpha: &originalAlpha) {
            originalAlpha = 0
        }

        return withAlphaComponent(originalAlpha * alpha)
    }

    func hexString(ignoresAlpha: Bool = false) -> String {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let redInt = Int(red * 255.0)
        let greenInt = Int(green * 255.0)
        let blueInt = Int(blue * 255.0)

        if ignoresAlpha {
            return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
        } else {
            let alphaInt = Int(alpha * 255.0)
            return String(format: "#%02X%02X%02X%02X", redInt, greenInt, blueInt, alphaInt)
        }
    }

    static func randomColor() -> UIColor {
        let red = Double.random(in: 0 ... 1)
        let green = Double.random(in: 0 ... 1)
        let blue = Double.random(in: 0 ... 1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
