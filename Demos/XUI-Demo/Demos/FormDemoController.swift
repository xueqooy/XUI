//
//  FormDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/3/4.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XUI
import XList
import XKit
import Combine

class FormDemoController: DemoController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.background1
                
        let embeddedFormView = FormView()
        embeddedFormView.itemSpacing = .XUI.spacing5
        embeddedFormView.backgroundConfiguration = .overlay()
        
        let embeddedFormRowItem = FormRow(embeddedFormView)

        let heightAdjustRow = createLableAndInputFieldAndButtonRow(labelText: "Form Height", keyboardType: .numberPad, buttonTitle: "Confirm") { text in
            UIView.animate(withDuration: 0.3) {
                if let height = NumberFormatter().number(from: text)?.floatValue, height > 0 {
                    embeddedFormRowItem.height = CGFloat(height)
                } else {
                    embeddedFormRowItem.height = nil
                }
                self.view.layoutIfNeeded()
            }
        }
        
        let labelField = MultilineInputField()
        labelField.label = "Label"
        labelField.placeholder = "Input field's label"
        
        let placehoderField = InputField()
        placehoderField.label = "Placeholder"
        placehoderField.placeholder = "Input field's placeholder"
        
        let createNewFieldButton = createButton(title: "Add Field") { [weak self] _ in
            let newField = InputField()
            newField.label = labelField.text
            newField.placeholder = placehoderField.text
            
            embeddedFormView.addItem(FormRow(newField))
            
            self?.hideKeyboard()
        }
        
        
        
        let nameField = MultilineInputField()
        nameField.label = "Name"
        nameField.placeholder = "Input your name"
        
        let countryField = InputField()
        countryField.label = "Country"
        countryField.placeholder = "Input your country"
        
        let addresssField = InputField()
        addresssField.label = "Address"
        addresssField.placeholder = "Input your address"
        addresssField.text = "中国福建省福州市鼓楼区"
        addresssField.isEnabled = false
        
        let codeTextSelector = MenuTextSelector((0...1000).map { "+" + String($0) })
        let mobileField = MobileNumberInputField(codeSelector: codeTextSelector)
        mobileField.label = "Mobile"
        mobileField.placeholder = "Input your mobile"
       
        let passwordField = PasswordInputField()
        passwordField.label = "Password"
        passwordField.placeholder = "Input your password"
        
        let nameRow = FormRow(nameField)
       
        let optionControl = OptionControl(style: .checkbox, titlePlacement: .leading, title: "Remember me")
        let linkedLabel = LinkedLabel()
        linkedLabel.set(text: "#Forgot Password#", linkTags: ["#"])
        let multiviewRow = FormRow([optionControl, SpacerView.flexible(.vertical), linkedLabel])
                            
        embeddedFormView.populate {
            nameRow
            
            FormRow(countryField)
                .bindingCustomSpacingAfter(to: nameRow.$isHidden.didChange) {
                    $0 ? 100 : 20
                }
            FormRow(addresssField)
                .bindingHidden(to: nameRow.$isHidden.didChange, toggled: true)
            
            FormRow(mobileField)
            multiviewRow
        }
        
        Queue.main.execute(.delay(3)) {
            nameRow.isHidden = true
            
            Queue.main.execute(.delay(3)) {
                nameRow.isHidden = false
            }
        }

        addRow(labelField, alignment: .fill)
        addRow(placehoderField, alignment: .fill)
        addRow(createNewFieldButton)
        addRow(heightAdjustRow)
        
        addTitle("Embbed Form")
        addItem(embeddedFormRowItem)
        
        
        addTitle("Form Section")
        
        let firstNameField = MultilineInputField()
        firstNameField.label = "First Name"
        firstNameField.placeholder = "Input your first name"

        let lastNameField = InputField()
        lastNameField.label = "Last Name"
        lastNameField.placeholder = "Input your last name"
        
        let firstNameFieldRow = FormRow(firstNameField)
        let lastNameFieldRow =  FormRow(lastNameField)
        
        
        let formSection = FormSection.card(
            itemSpacing: 20,
            automaticallyUpdatesVisibility: true) {
                
            firstNameFieldRow
            lastNameFieldRow
        }
        formSection.customSpacingAfter = 50

//        Queue.main.execute(.delay(3)) {
//            firstNameFieldRow.isHidden = true
//
//            Queue.main.execute(.delay(3)) {
//                lastNameFieldRow.isHidden = true
//                // 此时formSection的isHidden会自动设置为true
//                
//                Queue.main.execute(.delay(3)) {
//                    firstNameFieldRow.isHidden = false
//                    // 此时formSection的isHidden会自动设置为false
//                    
//                    lastNameFieldRow.isHidden = false
//                }
//            }
//        }
        
        addItem(formSection)
        addItem(FormSeparator())
    }
}
