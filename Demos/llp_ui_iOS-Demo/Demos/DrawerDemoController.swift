//
//  DrawerDemoController.swift
//  EDUI_Example
//
//  Created by 🌊 薛 on 2022/9/19.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import LLPUI

class DrawerDemoController: DemoController {
    
    private var hasInputField: Bool = false
    private var maximumExpandedHeight: CGFloat = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        addRow(createLableAndInputFieldAndButtonRow(labelText: "Max Height", keyboardType: .numberPad, buttonTitle: "Confirm") { [weak self] text in
            if let height = NumberFormatter().number(from: text)?.floatValue, height > 0 {
                self?.maximumExpandedHeight = CGFloat(height)
            } else {
                self?.maximumExpandedHeight = -1
            }
        })
        
        addRow(createLabelAndSwitchRow(labelText: "Input Field") { [weak self] isOn in
            self?.hasInputField = isOn
        })
        
        addRow(createButton(title: "Drawer", action: { [weak self] button in
            guard let self = self else { return }
            
            self.presentDrawer(sourceView: button, contentView: self.createDrawerContentView(), configuration: .init(presentationStyle: .automatic, presentationDirection: .up, resizingBehavior: .dismissOrExpand, preferredMaximumExpansionHeight: self.maximumExpandedHeight, permittedArrowDirections: Device.current.isPad ? .up : .any), animated: true)
        }))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func createDrawerContentView() -> UIView {
       
        let formView = FormView()
        formView.contentInset = .directionalZero
        formView.itemSpacing = 0
        
        let iconImageView = UIImageView(image: .init(named: "rubbish"))
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel(text: "Are you sure", textColor: Colors.title, font: Fonts.body1Bold, textAlignment: .center)
        
        let messageLabel = UILabel(text: "Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.Deleting an item permanently removes it and its contents.", textColor: Colors.bodyText1, font: Fonts.body2, textAlignment: .center, numberOfLines: 0)
               
        let deleteButton = createButton(title: "Delete", style: .primary) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        let cancelButton = createButton(title: "Cancel", style: .secondary) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        formView.addItem(FormRow(iconImageView))
        formView.addItem(FormSpacer(20))
        formView.addItem(FormRow(titleLabel))
        formView.addItem(FormSpacer(12))
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
    
    @discardableResult
    private func presentDrawer(sourceView: UIView? = nil,
                               barButtonItem: UIBarButtonItem? = nil,
                               contentController: UIViewController? = nil,
                               contentView: UIView? = nil,
                               configuration: DrawerController.Configuration,
                               animated: Bool = true) -> DrawerController {
        
        let controller: DrawerController
        if let sourceView = sourceView {
            controller = DrawerController(sourceView: sourceView, sourceRect: sourceView.bounds.insetBy(dx: sourceView.bounds.width / 2, dy: 0), configuration: configuration)
        } else if let barButtonItem = barButtonItem {
            controller = DrawerController(barButtonItem: barButtonItem, configuration: configuration)
        } else {
            preconditionFailure("Presenting a drawer requires either a sourceView or a barButtonItem")
        }
        
        controller.delegate = self
      
        if let contentView = contentView {
            // `preferredContentSize` can be used to specify the preferred size of a drawer,
            // but here we just define the width and allow it to calculate height automatically
//            controller.preferredContentSize.width = 100
            controller.contentView = contentView
        } else {
            controller.contentController = contentController
        }

        present(controller, animated: animated)

        return controller
    }
}

extension DrawerDemoController: DrawerControllerDelegate {
    
}
