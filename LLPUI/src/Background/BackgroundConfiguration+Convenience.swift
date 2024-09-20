//
//  BackgroundConfiguration+Convenience.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/9/19.
//

import UIKit

public extension BackgroundConfiguration {
    
    static func clear() -> BackgroundConfiguration {
        BackgroundConfiguration()
    }
    
    static func dimmingWhite() -> BackgroundConfiguration {
        var config = BackgroundConfiguration()
        config.fillColor = UIColor(white: 1, alpha: .LLPUI.dimmingAlpha)
        return config
    }
    
    static func dimmingBlack() -> BackgroundConfiguration {
        var config = BackgroundConfiguration()
        config.fillColor = UIColor(white: 0, alpha: .LLPUI.dimmingAlpha)
        return config
    }
    
    static func overlay(color: UIColor = .white, cornerStyle: CornerStyle = .fixed(.LLPUI.cornerRadius)) -> BackgroundConfiguration {
        var config = BackgroundConfiguration()
        config.fillColor = color
        config.cornerStyle = cornerStyle
      
        return config.applyingShadow()
    }
    
    func applyingStroke(color: UIColor, width: CGFloat = 1, cornerStyle: CornerStyle? = nil) -> BackgroundConfiguration {
        var config = self
        config.strokeWidth = 1
        config.strokeColor = color
        if let cornerStyle {
            config.cornerStyle = cornerStyle
        }
        
        return config
    }
    
    func applyingShadow(blurRadius: CGFloat = .LLPUI.shadowBlurRadius, offset: CGSize = .LLPUI.shadowOffset) -> BackgroundConfiguration {
        var config = self
        config.shadowColor = Colors.shadow
        config.shadowBlurRadius = blurRadius
        config.shadowOffset = shadowOffset
        return config
    }

}
