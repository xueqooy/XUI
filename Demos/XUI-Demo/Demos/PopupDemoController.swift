//
//  PopupDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/3/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XKit
import XUI

class PopupDemoController: DemoController {
    private var hasInputField: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        addRow(createLabelAndSwitchRow(labelText: "Input Field") { [weak self] isOn in
            self?.hasInputField = isOn
        })

        addRow(createButton(title: "Popup [x]", action: { [weak self] _ in
            guard let self = self else { return }

            self.presentPopup(contentView: self.createPopupContentView())
        }))

        addRow(createButton(title: "Popup [title x]", action: { [weak self] _ in
            guard let self = self else { return }

            self.presentPopup(title: "Save Quiz", contentView: self.createPopupContentView())
        }))

        addRow(createButton(title: "Popup [title]", action: { [weak self] _ in
            guard let self = self else { return }

            self.presentPopup(title: "Save Quiz", showsCancelButton: false, contentView: self.createPopupContentView())
        }))

        addRow(createButton(title: "Popup []", action: { [weak self] _ in
            guard let self = self else { return }

            self.presentPopup(showsCancelButton: false, contentView: self.createPopupContentView())
        }))
    }

    private func createPopupContentView() -> UIView {
        let formView = FormView()
        formView.contentInset = .directionalZero
        formView.itemSpacing = 0

        let iconImageView = UIImageView(image: .init(named: "rubbish"))
        iconImageView.contentMode = .scaleAspectFit

//        let titleLabel = UILabel(text: "Are you sure", textColor: Colors.title, font: Fonts.body1Bold, textAlignment: .center)

        let messageLabel = UILabel(text: "Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.", textColor: Colors.bodyText1, font: Fonts.body2, numberOfLines: 0)

        let deleteButton = createButton(title: "Delete", style: .primary) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        let cancelButton = createButton(title: "Cancel", style: .secondary) { [weak self] _ in
            self?.dismiss(animated: true)
        }

//        formView.addItem(FormRow(iconImageView))
//        formView.addItem(FormSpacer(20))
//        formView.addItem(FormRow(titleLabel))
//        formView.addItem(FormSpacer(12))
        formView.addItem(FormRow(messageLabel))
        formView.addItem(FormSpacer(20))

        if hasInputField {
            let textField = InputField()
            textField.label = "name"
            textField.placeholder = "Input your name"
            formView.addItem(FormRow(textField, alignment: .fill))
            formView.addItem(FormSpacer(20))

            let hideKeyboardButton = createButton(title: "Hide Keyboard", style: .primary) { [weak self] _ in
                self?.view.window?.endEditing(true)
            }
            formView.addItem(FormRow(hideKeyboardButton))
            formView.addItem(FormSpacer(12))
        }

        formView.addItem(FormRow(deleteButton))
        formView.addItem(FormSpacer(12))
        formView.addItem(FormRow(cancelButton))

        return formView
    }

    private func presentPopup(title: String? = nil, showsCancelButton: Bool = true, contentView: UIView? = nil, contentController: UIViewController? = nil, adjustsHeightForKeyboard: Bool = true) {
        let configuration = PopupController.Configuration(title: title, cancelAction: showsCancelButton ? .withoutHandler : nil, adjustsHeightForKeyboard: adjustsHeightForKeyboard)

        let popupController = PopupController(configuration: configuration)
        if let contentView = contentView {
            popupController.contentView = contentView
        } else if let contentController = contentController {
            popupController.contentController = contentController
        }

//        popupController.preferredContentSize = CGSize(width: 200, height: 2000)

//        Queue.main.execute(.delay(3)) {
//            popupController.title = nil
//        }

        present(popupController, animated: true)
    }
}
