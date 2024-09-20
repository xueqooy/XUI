//
//  PlainButtonConfigurationTransformer.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit

/// Apply extra transparency on configuration's colors based on the enabled state.
open class PlainButtonConfigurationTransformer: ButtonConfigurationTransforming {

    public init() {
    }
    
    open func resolvedConfiguration(for button: Button) -> ButtonConfiguration {
        var configuration = button.configuration
        
        update(&configuration, for: button)
        
        return configuration
    }
    
    open func update(_ configuration: inout ButtonConfiguration, for button: Button) {
        let isEnabled = button.isEnabled
        
        if let overlayAlpha = multiplicativeAlpha(for: isEnabled) {
            if shouldAutomaticallyAdjustForegroundAlpha {
                if let forgroundColor = configuration.foregroundColor ?? button.tintColor {
                    configuration.foregroundColor = forgroundColor.withMultiplicativeAlpha(overlayAlpha)
                }
                
                if let titleColor = configuration.titleColor {
                    configuration.titleColor = titleColor.withMultiplicativeAlpha(overlayAlpha)
                }
                
                if let subtitleColor = configuration.subtitleColor {
                    configuration.subtitleColor = subtitleColor.withMultiplicativeAlpha(overlayAlpha)
                }
            }
            
            if let backgroundFillColor = configuration.background?.fillColor {
                configuration.background?.fillColor = backgroundFillColor.withMultiplicativeAlpha(overlayAlpha)
            }
            
            if let backgroundStrokeColor = configuration.background?.strokeColor {
                configuration.background?.strokeColor = backgroundStrokeColor.withMultiplicativeAlpha(overlayAlpha)
            }
        }
    }
    
    /// Subclasses can override this function to return the extra transparency in different states.
    open func multiplicativeAlpha(for enabled: Bool) -> CGFloat? {
        if enabled {
            return nil
        } else {
            return 0.35
        }
    }
    
    open var shouldAutomaticallyAdjustForegroundAlpha: Bool {
        true
    }

    public var respondsToEnabledChanged: Bool {
        true
    }
}
