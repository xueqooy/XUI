//
//  GridDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/3/7.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI

class GridDemoController: DemoController {
    var gridView: GridView!

    var columnCount: Int = 4 {
        didSet {
            gridView.columnCount = columnCount
        }
    }

    var spacing: CGFloat = 10 {
        didSet {
            gridView.spacing = spacing
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let subviews = (0 ..< 10).map { _ in
            createSubview()
        }

        addRow(createLableAndInputFieldAndButtonRow(labelText: "Column", keyboardType: .numberPad, buttonTitle: "Confirm", buttonAction: { [weak self] text in
            self?.columnCount = Int(text) ?? 4
        }))

        addRow(createLableAndInputFieldAndButtonRow(labelText: "Spacing", keyboardType: .numberPad, buttonTitle: "Confirm", buttonAction: { [weak self] text in
            if let spacing = NumberFormatter().number(from: text)?.floatValue, spacing >= 0 {
                self?.spacing = CGFloat(spacing)
            } else {
                self?.spacing = 10
            }
        }))

        gridView = GridView(rowLayout: .filled)
        gridView.spacing = spacing
        gridView.columnCount = columnCount
        gridView.setArrangedSubviews(subviews)

        addRow(gridView, height: 500, alignment: .fill)
    }

    private func createSubview() -> UIView {
        let view = UIView()
        view.backgroundColor = .randomColor()
        return view
    }
}
