//
//  SteppedProgressDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/3/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI

class SteppedProgressDemoController: DemoController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let step0 = SteppedProgressView(numberOfSteps: 3)
        let step1 = SteppedProgressView(numberOfSteps: 3)
        step1.currentStep = 1
        let step2 = SteppedProgressView(numberOfSteps: 3)
        step2.currentStep = 2
        
        addRow(step0, alignment: .fill)
        addRow(step1, alignment: .fill)
        addRow(step2, alignment: .fill)
    }
}
