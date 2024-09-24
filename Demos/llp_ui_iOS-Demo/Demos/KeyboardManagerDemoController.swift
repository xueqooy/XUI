//
//  KeyboardManagerDemoController.swift
//  EDUI_Example
//
//  Created by 🌊 薛 on 2022/10/21.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import LLPUI
import Combine

class KeyboardManagerDemoController: DemoController {
    
    private let textField1 = InputField(placeholder: "Text Field")
    private let textField2: InputField = {
        let textField = InputField()
        textField.keyboardType = .numberPad
        textField.placeholder = "Number Field"
        return textField
    }()
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "My position base on the height of the docked keyboard"
        return label
    }()
    
    private let keyboardManager = KeyboardManager()
        
    private var usesNativeKeyboardLayoutGuide: Bool = false {
        didSet {
            guard usesNativeKeyboardLayoutGuide != oldValue else {
                return
            }
            
            updateLabelConstraints()
            
            followUndockedKeyboardRow.isHidden = !usesNativeKeyboardLayoutGuide
        }
    }
    
    private var followsUndockedKeyboard: Bool = false {
        didSet {
            if #available(iOS 15.0, *) {
                view.keyboardLayoutGuide.followsUndockedKeyboard = followsUndockedKeyboard
                label.text = followsUndockedKeyboard ? "My position base on the height of the docked or undocked keyboard" : "My position base on the height of the docked keyboard"
            }
        }
    }
    
    private lazy var followUndockedKeyboardRow = createLabelAndSwitchRow(labelText: "Follows undocked keyboard") { [weak self] isOn in
        guard let self = self else {
            return
        }
        self.followsUndockedKeyboard = isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            addRow(createLabelAndSwitchRow(labelText: "Use native keyboard layout guide (iOS 15)") { [weak self] isOn in
                guard let self = self else {
                    return
                }
                self.usesNativeKeyboardLayoutGuide = isOn
            })
            
            if Device.current.isPad {
                followUndockedKeyboardRow.isHidden = true
                addRow(followUndockedKeyboardRow)
            }
            
            addSpacer(100)
        }

        keyboardManager.didReceiveEventPublisher
            .sink { [weak self] (event, _) in
                guard let self = self else {
                    return
                }
                
                print("distance: \(KeyboardManager.distanceFromMinYToBottom(of: self.view, ignoresUndockedKeyboard: false)),   isFloating: \(KeyboardManager.isKeyboardFloating)")
            }.store(in: &cancellables)
        
        addRow(textField1)
        addRow(textField2)
    
        view.addSubview(label)
        updateLabelConstraints()
    }
    
    private func updateLabelConstraints() {
        label.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            if #available(iOS 15.0, *) {
                if self.usesNativeKeyboardLayoutGuide {
                    make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
                    return
                }
            }
            make.bottom.equalTo(view.dockedKeyboardLayoutGuide.snp.top)
        }
    }
}
