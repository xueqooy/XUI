//
//  ActionSheetButtonConfigurationTransformer.swift
//  XUI
//
//  Created by xueqooy on 2023/10/13.
//

import Foundation

public class ActionSheetButtonConfigurationTransformer: PlainButtonConfigurationTransformer {
    public override func update(_ configuration: inout ButtonConfiguration, for button: Button) {
        configuration.titleColor = Colors.title
        configuration.titleFont = Fonts.body1Bold
        configuration.imageSize = .init(width: 22, height: 22)
        configuration.imagePadding = .XUI.spacing3
        configuration.foregroundColor = Colors.teal
        
        super.update(&configuration, for: button)
    }
}
