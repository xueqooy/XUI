//
//  DatePickerDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2024/4/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI
import Combine

class DatePickerDemoController: DemoController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd h:mm a"
        
                
        let dateSelector = DateTextSelector(dateFormat: "yyyy/MM/dd")
        let dateField = SelectInputField(selector: dateSelector, label: "Due Date", placeholder: "Pick a date")
        
        let timePickerField = TimePickerField(label: "Due Time")
        
        let datePickerField = DatePickerField(label: "Due On", placeholder: "Pick a date")
        
        dateSelector.$date.didChange
            .sink { date in
                print("Due Date -> \(date != nil ? dateFormatter.string(from: date!) : "nil")")
            }
            .store(in: &cancellables)
        
        timePickerField.$time.didChange
            .sink { time in
                print("Due Time -> \(time)")
            }
            .store(in: &cancellables)
        
        datePickerField.$date.didChange
            .sink { date in
                print("Due On -> \(date != nil ? dateFormatter.string(from: date!) : "nil")")
            }
            .store(in: &cancellables)
        
        let validationSegmentControl = SegmentControl(style: .secondLevel, items: ["None", "Validating", "Success", "Error"])
        validationSegmentControl.selectedSegmentIndex = 0
        validationSegmentControl.selectedSegmentIndexPublisher
            .sink { index in
                let validationState: Field.ValidationState = switch index {
                case 1:
                    Field.ValidationState.validating
                case 2:
                    Field.ValidationState.success("Success")
                case 3:
                    Field.ValidationState.error("Error")
                default:
                    Field.ValidationState.none
                }
                
                dateField.validationState = validationState
                
                timePickerField.validationState = validationState
                
                datePickerField.validationState = validationState
            }
            .store(in: &cancellables)
        
        let applyCurrentDateButton = createButton(title: "Apply Current Date", style: .primarySmall) { _ in
            let currentDate = Date()
            
            dateSelector.date = currentDate
            
            timePickerField.time = .time(from: currentDate)
            
            datePickerField.date = currentDate
        }
        
        let clearButton = createButton(title: "Clear") { _ in
            dateSelector.date = nil
            
            timePickerField.time = .init()
            
            datePickerField.date = nil
        }
        
        let isEnabledSwitch = createLabelAndSwitchRow(labelText: "Enabled", isOn: true) { isOn in
            dateField.isEnabled = isOn
            
            timePickerField.isEnabled = isOn
            
            datePickerField.isEnabled = isOn
        }
        
        addItem(
            FormSection.card(itemSpacing: 20, components: {
                FormRow(dateField)
                FormRow(timePickerField)
                FormRow(datePickerField)
                FormRow(isEnabledSwitch, alignment: .center)
                FormRow(validationSegmentControl, alignment: .center)
                FormRow(applyCurrentDateButton, alignment: .center)
                FormRow(clearButton, alignment: .center)
            })
        )
    }
}
