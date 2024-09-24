//
//  CodeFieldDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/3/7.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI
import LLPUtils

class CodeFieldDemoController: DemoController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let codeField = CodeField(label: "Active State")
        
        codeField.addTarget(self, action: #selector(Self.inputCompleted), for: .primaryActionTriggered)
        
        codeField.editingBeganAction = { _ in
            print("eding began")
        }
        
        codeField.editingEndedAction = { _ in
            print("eding ended")
        }
        
        codeField.editingChangedAction = { view in
            print(view.text)
        }
        
        codeField.inputCompletedAction = { view in
            print("completed \(view.text)")
        }
        
        let disabledCodeField = CodeField(label: "Disabled State")
        disabledCodeField.isEnabled = false
        disabledCodeField.text = "123"
        
        
        let fourCodeField = CodeField(label: "4-Code", length: 4)
        
        var validationTimer: LLPUtils.Timer? = nil
        
        let validationCodeField = CodeField(label: "123456 is valid")
        validationCodeField.editingChangedAction = { view in
            if view.isCompleted {
                view.validationState = .validating
                
                validationTimer = LLPUtils.Timer(interval: 3) {
                    view.validationState = view.text == "123456" ? .success("Code is valid") : .error("Code is invalid")
                }
                validationTimer?.start()
    
            } else {
                validationTimer = nil
                
                view.validationState = .none
            }
        }
        
        
        addRow(codeField)
        
        addRow(createLableAndInputFieldAndButtonRow(labelText: "Code", keyboardType: .numberPad, buttonTitle: "Inset", buttonAction: { text in
            codeField.insertText(text)
        }))
        
        addRow(disabledCodeField)
        addRow(fourCodeField)
        addRow(validationCodeField)
    }
    
    @objc private func inputCompleted(_ sender: CodeField) {
        print("target-action completed \(sender.text)")
    }
}
