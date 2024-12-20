//
//  InputFieldDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/2/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Combine
import UIKit
import XKit
import XList
import XUI

class InputFieldDemoController: DemoController {
    private var isValidationEnabled: Bool = false {
        didSet {
            for field in fields {
                updateValidationState(for: field)
            }
        }
    }

    let searchField = SearchInputField(label: "Search", placeholder: "Search")

    let largeSearchField = SearchInputField(style: .large, placeholder: "Search")

    private var fields = [Field]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.background1

        let nameField = InputField(label: "Username", placeholder: "Input your username")

        let passwordField = PasswordInputField(label: "Password", placeholder: "Input your password")
        passwordField.textContentType = .newPassword
        passwordField.isStrengthIndicatorEnabled = true
        passwordField.textPublisher
            .sink { [weak passwordField] text in
                guard let field = passwordField else {
                    return
                }

                let text = text ?? ""

                if text.count < 5 {
                    field.strengthLevel = .weak
                } else if text.count < 10 {
                    field.strengthLevel = .moderate
                } else {
                    field.strengthLevel = .strong
                }
            }
            .store(in: &cancellables)

        let codeTextSelector = MenuTextSelector((0 ... 1000).map { "+" + String($0) })
        let mobileField = MobileNumberInputField(codeSelector: codeTextSelector, label: "Mobile", placeholder: "Input your mobile number")

        let dateDrawerTextSelector = DateTextSelector(presentationStyle: .drawer)
        let dateDrawerField = SelectInputField(selector: dateDrawerTextSelector, label: "Date (Drawer)", placeholder: "Pick a date", image: Icons.calendar)

        let datePopoverTextSelector = DateTextSelector(presentationStyle: .popover)
        let datePopoverField = SelectInputField(selector: datePopoverTextSelector, label: "Date (Popover)", placeholder: "Pick a date", image: Icons.calendar)

        let yearTextSelector = MenuTextSelector((1999 ... 2050).map { String($0) })
        let yearField = SelectInputField(selector: yearTextSelector, label: "Year", placeholder: "Pick a year", image: Icons.dropdown)
        yearField.text = "2024"

        let addresssField = InputField(label: "Address", placeholder: "Input your address")
        addresssField.text = "中国福建省福州市鼓楼区"

        let lengthLimitField = InputField(label: "7-digit code", placeholder: "Allow up to 7 characters in length")
        lengthLimitField.maximumTextLength = 7

        let descriptionField = MultilineInputField(label: "Description", placeholder: "Input description")

        let lengthLimitMulilineField = MultilineInputField(label: "100 characters", placeholder: "Allow up to 100 characters")
        lengthLimitMulilineField.shouldDisplayTextLengthLimitPrompt = true
        lengthLimitMulilineField.maximumTextLength = 100

        let messageField = MessageInputField(label: "Comment", placeholder: "Write a comment...")

        let customField = CustomField()
        customField.label = "Custom Field"
        customField.contentInset = .directional(uniformValue: .XUI.spacing4)

        fields.append(largeSearchField)
        fields.append(searchField)
        fields.append(nameField)
        fields.append(passwordField)
        fields.append(dateDrawerField)
        fields.append(datePopoverField)
        fields.append(yearField)
        fields.append(mobileField)
        fields.append(addresssField)
        fields.append(lengthLimitField)
        fields.append(descriptionField)
        fields.append(lengthLimitMulilineField)
        fields.append(messageField)
        fields.append(customField)

        addRow(createLabelAndSwitchRow(labelText: "Validation Enabled", switchAction: { [weak self] isOn in
            self?.isValidationEnabled = isOn
        }))

        addDescription("try to input 'success' or 'error'")

        addRow(createLabelAndSwitchRow(labelText: "Toggle Enabled", switchAction: { [weak self] _ in
            self?.fields.forEach { field in
                field.isEnabled.toggle()
            }
        }))

        for field in fields {
            if let field = field as? InputField {
                field.addTarget(self, action: #selector(Self.textChanged(sender:)), for: .editingChanged)
            }
            addRow(field, alignment: .fill)
        }
    }

    @objc private func textChanged(sender: InputField) {
        print(sender.text ?? "")

        updateValidationState(for: sender)
    }

    private func updateValidationState(for field: Field) {
        if isValidationEnabled {
            if let field = field as? InputField {
                if field.text == "success" {
                    field.validationState = .success("Success")
                } else if field.text == "error" {
                    field.validationState = .error("Error")
                } else {
                    field.validationState = field.text?.isEmpty == true ? .none : .validating
                }
            } else {
                field.validationState = .success("Success")
            }
        } else {
            field.validationState = .none
        }
    }
}

extension InputFieldDemoController: Editable {
    var editableResponder: UIResponder? {
        largeSearchField
    }
}

class CustomField: Field {
    override func makeContentView() -> UIView {
        ToastView(style: .note, message: "This is a custom field")
    }
}
