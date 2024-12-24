//
//  ButtonDemoController.swift
//  EDUI_Example
//
//  Created by 🌊 薛 on 2022/9/19.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import XKit
import XUI

class ButtonDemoController: DemoController {
    private var mainColor: UIColor = Colors.teal {
        didSet {
            for button in buttons {
                if let cardButtonConfigurationTransformer = button.configurationTransformer as? CardButtonConfigurationTransformer {
                    cardButtonConfigurationTransformer.strokeColor = mainColor
                    button.configuration.titleColor = mainColor
                } else if let designedButtonConfigurationTransformer = button.configurationTransformer as? DesignedButtonConfigurationTransformer {
                    designedButtonConfigurationTransformer.mainColor = mainColor
                }

                button.updateConfiguration()
            }
        }
    }

    private var buttons = [Button]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 14.0, *) {
            let colorWell = UIColorWell()
            colorWell.selectedColor = mainColor
            colorWell.addTarget(self, action: #selector(Self.colorWellDidChange(_:)), for: .valueChanged)

            addRow(colorWell, alignment: .center)
            addSeparator()
        }

        for style in DesignedButtonConfigurationTransformer.Style.allCases {
            addTitle(style.description)

            var configuration = ButtonConfiguration()
            configuration.title = "Button"

            let button = Button(designStyle: style, title: "Button") 

            let disabledButton = Button(configuration: configuration, configurationTransformer: DesignedButtonConfigurationTransformer(style: style))
            disabledButton.isEnabled = false

            addRow(button)
            addRow(disabledButton)

            buttons.append(contentsOf: [button, disabledButton])
        }

        addTitle("Card")

        var cardConfig = ButtonConfiguration()
        cardConfig.title = "Button"
        cardConfig.titleColor = mainColor
        let cardButton = Button(configuration: cardConfig, configurationTransformer: CardButtonConfigurationTransformer(strokeColor: mainColor)) { button in
            button.isSelected.toggle()
        }

        addRow(cardButton)

        buttons.append(cardButton)
    }

    @available(iOS 14.0, *)
    @objc private func colorWellDidChange(_ sender: UIColorWell) {
        mainColor = sender.selectedColor ?? Colors.teal
    }
}
