//
//  CardButtonConfigurationTransformer.swift
//  XUI
//
//  Created by xueqooy on 2023/5/4.
//

import UIKit

open class CardButtonConfigurationTransformer: PlainButtonConfigurationTransformer {
    private lazy var baseConfiguration: ButtonConfiguration = {
        var bg = BackgroundConfiguration.overlay()
        bg.stroke.width = 1
        bg.stroke.color = strokeColor

        var conf = ButtonConfiguration()
        conf.background = bg

        return conf
    }()

    public let contentInset: Insets
    public var strokeColor: UIColor {
        didSet {
            baseConfiguration.background?.stroke.color = strokeColor
        }
    }

    public init(strokeColor: UIColor = Colors.teal, contentInset: Insets = .nondirectional(top: .XUI.spacing5, left: .XUI.spacing6, bottom: .XUI.spacing5, right: .XUI.spacing6)) {
        self.strokeColor = strokeColor
        self.contentInset = contentInset
    }

    override open func update(_ configuration: inout ButtonConfiguration, for button: Button) {
        let isSelected = button.isSelected

        var template: ButtonConfiguration = baseConfiguration
        template.background?.stroke.width = isSelected ? 1.0 : 0.0

        configuration.background = template.background
        configuration.contentInsets = contentInset

        super.update(&configuration, for: button)
    }
}
