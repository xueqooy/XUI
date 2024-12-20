//
//  SeparatorDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/3/7.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI

class SeparatorDemoController: DemoController {
    override func viewDidLoad() {
        super.viewDidLoad()

        addTitle("Separator")
        addRow(SeparatorView())

        addTitle("Separator With Padding")
        addRow(SeparatorView(leadingPadding: 50, trailingPadding: 50))

        addTitle("Shadow")
        addRow(SeparatorView(color: Colors.shadow))

        addTitle("Bold Separator")
        addRow(SeparatorView(thickness: 2))

        addTitle("Horizontal Separator")
        addRow(HSeparatorView())

        addTitle("Horizontal Separator With Padding")
        addRow(HSeparatorView(leadingPadding: 20, trailingPadding: 20))

        addTitle("Vertical Separator")
        addRow(VSeparatorView(), height: 100)

        addTitle("Vertical Separator With Padding")
        addRow(VSeparatorView(leadingPadding: 20, trailingPadding: 20), height: 100)

        addTitle("Form Separator")
        addItem(FormSeparator())

        addTitle("Form Separator With Padding")
        addItem(FormSeparator(leadingPadding: 50, trailingPadding: 50))
    }
}
