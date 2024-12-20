//
//  TripleImageDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/9/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI

class TripleImageDemoController: DemoController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let source = TripleImageView.Source.url(.randomImageURL(), nil)
        let height = (UIApplication.shared.keyWindows.first?.bounds.width ?? 370 - contentInset.horizontal) / 2

        func tapHandler(view _: TripleImageView, index: Int) {
            print("tap image at index \(index)")
        }

        let items = [
            ("Single Image", TripleImageView(sources: [source], tapHandler: tapHandler)),
            ("Two Images", TripleImageView(sources: .init(repeating: source, count: 2), tapHandler: tapHandler)),
            ("Third Images", TripleImageView(sources: .init(repeating: source, count: 3), tapHandler: tapHandler)),
            ("Four Images", TripleImageView(sources: .init(repeating: source, count: 4), tapHandler: tapHandler)),
        ]

        for item in items {
            addTitle(item.0)
            addRow(item.1, height: height, alignment: .fill)
        }
    }
}
