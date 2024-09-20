//
//  CardButtonConfigurationTransformer.swift
//  LLPUI
//
//  Created by xueqooy on 2023/5/4.
//

import UIKit

open class CardButtonConfigurationTransformer: PlainButtonConfigurationTransformer {

    private lazy var baseConfiguration: ButtonConfiguration = {
        var bg = BackgroundConfiguration.overlay()
        bg.strokeWidth = 1
        bg.strokeColor = strokeColor
        
        var conf = ButtonConfiguration()
        conf.background = bg
        
        return conf
    }()
        
    public let contentInset: Insets
    public var strokeColor: UIColor {
        didSet {
            baseConfiguration.background?.strokeColor = strokeColor
        }
    }
    
    public init(strokeColor: UIColor = Colors.vibrantTeal, contentInset: Insets = .nondirectional(top: .LLPUI.spacing5, left: .LLPUI.spacing6, bottom: .LLPUI.spacing5, right: .LLPUI.spacing6)) {
        self.strokeColor = strokeColor
        self.contentInset = contentInset
    }
    
    open override func update(_ configuration: inout ButtonConfiguration, for button: Button) {
        let isSelected = button.isSelected
                
        var template: ButtonConfiguration = baseConfiguration
        template.background?.strokeWidth = isSelected ? 1.0 : 0.0

        configuration.background =  template.background
        configuration.contentInsets = contentInset

        super.update(&configuration, for: button)
    }
}
