//
//  ColorPickerDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2024/2/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import XUI

class ColorPickerDemoController: DemoController {
    private var pendingColor: UIColor? = .black

    private var colors = ColorPicker.defaultColors

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 14.0, *) {
            let colorWell = UIColorWell()
            colorWell.selectedColor = .black
            colorWell.addTarget(self, action: #selector(Self.colorWellDidChange(_:)), for: .valueChanged)

            let addButton = createButton(title: "Add") { [weak self] _ in
                guard let self, let pendingColor = self.pendingColor else { return }

                self.colors.append(pendingColor)

                self.showToast(style: .success, "Color added")
            }

            addRow([colorWell, addButton], itemSpacing: 15, alignment: .center, distribution: .fill)
        }

        addRow(createButton(title: "Show Color Picker", action: { [weak self] button in
            guard let self else { return }

            let colorPicker = ColorPicker(colors: self.colors, selectedColor: self.view.backgroundColor, title: "Change Background Color", confirmationButtonTitle: "Apply") { [weak self] color in
                guard let self else { return }

                self.view.backgroundColor = color
            }

            colorPicker.show(in: self, sourceView: button)
        }))
    }

    @available(iOS 14.0, *)
    @objc private func colorWellDidChange(_ sender: UIColorWell) {
        pendingColor = sender.selectedColor
    }
}
