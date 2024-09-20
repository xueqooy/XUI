//
//  ActionBarButtonConfigurationTransformer.swift
//  LLPUI
//
//  Created by xueqooy on 2024/3/28.
//

import Foundation

class ActionBarButtonConfigurationTransformer: PlainButtonConfigurationTransformer {
        
    private let debug: Bool
    
    init(debug: Bool = false) {
        self.debug = debug
        
        super.init()
    }
    
    public override func update(_ configuration: inout ButtonConfiguration, for button: Button) {
        
        configuration.titleFont = Fonts.body2
        configuration.imageSize = CGSize(width: 16, height: 16)
        configuration.imagePadding = .LLPUI.spacing2
        configuration.imagePlacement = .leading
        configuration.foregroundColor = Colors.vibrantTeal
        configuration.contentInsets = .nondirectional(uniformValue: .LLPUI.spacing2)
        
        if debug {
            configuration.background?.fillColor = Colors.background
        }
        
        super.update(&configuration, for: button)
    }
}