//
//  ToastDemoController.swift
//  EDUI_Example
//
//  Created by 🌊 薛 on 2022/9/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import LLPUI
import LLPUtils

class ToastDemoController: DemoController {
    
    private var actionTitle: String? = nil {
        didSet {
            if let actionTitle {
                fixedNote.configuration.action = .init(title: actionTitle, handler: {
                    print("Action Triggered")
                })
            } else {
                fixedNote.configuration.action = nil
            }

        }
    }
    
    private let fixedNote = ToastView(configuration: .init(style: .note, message: "Lorem ipsum dolor"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRow(createLableAndInputFieldAndButtonRow(labelText: "Action Title", buttonTitle: "Apply") { [weak self] in
            guard let self else { return }
            
            if $0.isEmpty {
                self.actionTitle = nil
            } else {
                self.actionTitle = $0
            }
        })
        
        addRow(fixedNote)
    
        addRow(createButton(title: "Success Toast", action: { [weak self] _ in
            guard let self = self else { return }
            
            self.presentToast(style: .success, inViewController: self)
        }))
        
        addRow(createButton(title: "Error Toast", action: { [weak self] _ in
            guard let self = self else { return }
            
            self.presentToast(style: .error, inViewController: self)
        }))
        
        addRow(createButton(title: "Note Toast", action: { [weak self] _ in
            guard let self = self else { return }
            
            self.presentToast(style: .note, inViewController: self)
        }))
        
        addRow(createButton(title: "Warning Toast", action: { [weak self] _ in
            guard let self = self else { return }
            
            self.presentToast(style: .warning, inViewController: self)
        }))
    
        addSpacer(300)
        
        addRow(createButton(title: "Success Toast From Here") { [weak self] button in
            guard let self = self else { return }
            
            self.presentToast(style: .success, inView: self.view, from: button)
        })
    }
    
    private func presentToast(style: ToastView.Style, inView view: UIView? = nil, inViewController viewController: UIViewController? = nil, from anchorView: UIView? = nil, animated: Bool = true, completion: ((ToastView) -> Void)? = nil) {
        let ToastView = ToastView(configuration: .init(style: style, message: " Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua", action: actionTitle != nil ? .init(title: actionTitle!, handler: {  print("Action Triggered") }) : nil))
        
        let compl: (ToastView) -> Void = { notifView in
            completion?(notifView)
            notifView.hide(after: .LLPUI.autoHideDelay, animated: animated, completion: nil)
        }
        
        if let view = view {
            ToastView.show(in: view, from: anchorView, animated: animated, completion: compl)
        } else if let viewController = viewController {
            ToastView.show(from: viewController, animated: animated, completion: compl)
        }
        
    }
}
