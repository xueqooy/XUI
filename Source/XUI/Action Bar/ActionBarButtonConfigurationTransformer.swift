//
//  ActionBarButtonConfigurationTransformer.swift
//  XUI
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

    override public func update(_ configuration: inout ButtonConfiguration, for button: Button) {
        configuration.titleFont = Fonts.body2
        configuration.imageSize = CGSize(width: 16, height: 16)
        configuration.imagePadding = .XUI.spacing2
        configuration.imagePlacement = .leading
        configuration.foregroundColor = Colors.teal
        configuration.contentInsets = .nondirectional(uniformValue: .XUI.spacing2)

        if debug {
            configuration.background?.fillColor = Colors.background1
        }

        super.update(&configuration, for: button)
    }
}
