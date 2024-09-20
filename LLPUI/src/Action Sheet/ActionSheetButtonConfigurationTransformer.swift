//
//  ActionSheetButtonConfigurationTransformer.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/13.
//

import Foundation

public class ActionSheetButtonConfigurationTransformer: PlainButtonConfigurationTransformer {
    public override func update(_ configuration: inout ButtonConfiguration, for button: Button) {
        configuration.titleColor = Colors.title
        configuration.titleFont = Fonts.subtitle1
        configuration.imageSize = .init(width: 22, height: 22)
        configuration.imagePadding = .LLPUI.spacing3
        configuration.foregroundColor = Colors.vibrantTeal
        
        super.update(&configuration, for: button)
    }
}
