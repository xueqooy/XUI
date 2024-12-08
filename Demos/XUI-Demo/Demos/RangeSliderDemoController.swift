//
//  RangeSliderDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2024/1/23.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XUI
import XKit
import Combine

class RangeSliderDemoController: DemoController {
    
    private let slider = RangeSlider(minimumValue: 0, maximumValue: 100, stepValue: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.controlEventPublisher(for: .valueChanged)
            .sink { [weak self] in
                guard let self else { return }
                
                print("Lower: \(self.slider.lowerValue), Upper: \(self.slider.upperValue)")
            }
            .store(in: &cancellables)
        
                
        addDescription("Step Value (0 means the step is disabled)")
        
        let stepperLabel = UILabel(text: "\(slider.stepValue)", textColor: Colors.title, font: Fonts.body2Bold)
        
        let stepper = UIStepper()
        stepper.value = slider.stepValue
        stepper.stepValue = 0.5
        stepper.controlEventPublisher(for: .valueChanged)
            .sink { [weak stepper, weak stepperLabel, weak self] in
                guard let stepper, let stepperLabel, let self else { return }
                
                stepperLabel.text = "\(stepper.value)"
                self.slider.stepValue = stepper.value
            }
            .store(in: &cancellables)
        
        addRow([stepperLabel, stepper], itemSpacing: .XUI.spacing5, alignment: .center)

        
        addDescription("Minimum Span")
        
        let stepperLabel1 = UILabel(text: "\(slider.minimumSpan)", textColor: Colors.title, font: Fonts.body2Bold)
        
        let stepper1 = UIStepper()
        stepper1.value = slider.minimumSpan
        stepper1.stepValue = 0.5
        stepper1.controlEventPublisher(for: .valueChanged)
            .sink { [weak stepper1, weak stepperLabel1, weak self] in
                guard let stepper1, let stepperLabel1, let self else { return }
                
                stepperLabel1.text = "\(stepper1.value)"
                self.slider.minimumSpan = stepper1.value
            }
            .store(in: &cancellables)
        
        addRow([stepperLabel1, stepper1], itemSpacing: .XUI.spacing5, alignment: .center)

        
        addRow(slider, alignment: .fill)
                
        
        addTitle("Custom Text")
        
        let levels = (0..<20).map { "Level \($0)" }
        let slider = RangeSlider(maximumValue: Double(levels.count) - 1, stepValue: 1, minimumSpan: 1) {
            levels[Int($0)]
        }
        addRow(slider, alignment: .fill)
    }
}
