//
//  CountdownTimerDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2024/7/8.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XUI
import XKit
import Combine

class CountdownTimerDemoController: DemoController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ct1 = CountdownTimerView(title: "Time Left:", totalSeconds: 3605)
        
        let ct2 = CountdownTimerView(totalSeconds: 60)
        
        let spacerBesideCt1 =  HSpacerView(0, huggingPriority: .required, compressionResistancePriority: .required)
        
        let startButton = Button(designStyle: .primary, title: "Start") { _ in
            ct1.start()
            ct2.start()
        }
        
        let stopButton = Button(designStyle: .primary, title: "Stop") { _ in
            ct1.stop()
            ct2.stop()
        }
        
        let sliderView = UISlider()
        sliderView.minimumValue = 0
        sliderView.maximumValue = 500
        sliderView.value = 0
        sliderView.valuePublisher
            .sink { spacing in
                spacerBesideCt1.spacing = CGFloat(spacing)
            }
            .store(in: &cancellables)
        
        ct1.remainingSecondsPublisher
            .sink { seconds in
                print("Remaining Seconds -> \(seconds)")
            }
            .store(in: &cancellables)
        
        addRow([ct1, spacerBesideCt1], alignment: .center)
        addRow(ct2)
        
        addRow(sliderView, alignment: .fill)
        addRow(startButton)
        addRow(stopButton)
        
        Queue.main.execute(.delay(3)) {
            ct1.remainingSeconds = 1500
        }
    }
}
