//
//  TripleImageDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/9/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI

class TripleImageDemoController: DemoController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let source = TripleImageView.Source.url(.randomImageURL(), nil)
        let height = (UIApplication.shared.keyWindows.first?.bounds.width ?? 370 - contentInset.horizontal) / 2
        
        func tapHandler(view: TripleImageView, index: Int) {
            print("tap image at index \(index)")
        }
        
        let items = [
            ("Single Image", TripleImageView(sources: [source], tapHandler: tapHandler)),
            ("Two Images", TripleImageView(sources: .init(repeating: source, count: 2), tapHandler: tapHandler)),
            ("Third Images", TripleImageView(sources: .init(repeating: source, count: 3), tapHandler: tapHandler)),
            ("Four Images", TripleImageView(sources: .init(repeating: source, count: 4), tapHandler: tapHandler))
        ]
        
        items.forEach {
            addTitle($0.0)
            addRow($0.1, height: height, alignment: .fill)
        }
    }
    
    
}
