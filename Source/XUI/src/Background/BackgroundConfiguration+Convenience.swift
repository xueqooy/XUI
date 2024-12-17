//
//  BackgroundConfiguration+Convenience.swift
//  XUI
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
        config.fillColor = UIColor(white: 1, alpha: .XUI.dimmingAlpha)
        return config
    }
    
    static func dimmingBlack() -> BackgroundConfiguration {
        var config = BackgroundConfiguration()
        config.fillColor = UIColor(white: 0, alpha: .XUI.dimmingAlpha)
        return config
    }
    
    static func overlay(color: UIColor = .white, cornerStyle: CornerStyle = .fixed(.XUI.cornerRadius)) -> BackgroundConfiguration {
        var config = BackgroundConfiguration()
        config.fillColor = color
        config.cornerStyle = cornerStyle
      
        return config.applyingShadow()
    }
    
    func applyingStroke(color: UIColor, width: CGFloat = 1, cornerStyle: CornerStyle? = nil) -> BackgroundConfiguration {
        var config = self
        config.stroke.width = 1
        config.stroke.color = color
        if let cornerStyle {
            config.cornerStyle = cornerStyle
        }
        
        return config
    }
    
    func applyingShadow(blurRadius: CGFloat = .XUI.shadowBlurRadius, offset: CGSize = .XUI.shadowOffset) -> BackgroundConfiguration {
        var config = self
        config.shadow.color = Colors.shadow
        config.shadow.blurRadius = blurRadius
        config.shadow.offset = offset
        return config
    }

}
