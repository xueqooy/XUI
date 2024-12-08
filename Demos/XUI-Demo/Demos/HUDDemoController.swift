//
//  HUDDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2024/3/14.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import XUI
import XKit

class HUDDemoController: DemoController {
        
    private let hud = HUD()
    
    private var segmentIndex: Int = 0 {
        didSet {
            updateContentType()
        }
    }
     
    private var hudText: String? {
        didSet {
            updateContentType()
        }
    }
    
    private var hudActionTitle: String?
    
    private var hudContentType: HUD.ContentType = .activity()
    
    private var interactionEnabled: Bool = false
    
    private var hideTimer: XKit.Timer?
    private var sharedHUDHideTimer: XKit.Timer?
    
    private var usesSharedHUD: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.background1

        addSpacer(200)
        
        let items: [SegmentControl.Item] = ["Activity", "Text"]
        
        let segmentControl = SegmentControl(style: .toggle, items: items)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectionChanged = { [weak self] control in
            guard let self else { return }
            
            self.segmentIndex = control.selectedSegmentIndex
        }
        addRow(segmentControl)
        
        let textField = InputField(label: "Text", placeholder: "Text for HUD")
        textField.textPublisher
            .sink { [weak self] text in
                self?.hudText = text
            }
            .store(in: &cancellables)
        addRow(textField, alignment: .fill)
        
        
        let actionField = InputField(label: "Action", placeholder: "Action for HUD")
        actionField.textPublisher
            .sink { [weak self] text in
                self?.hudActionTitle = text
            }
            .store(in: &cancellables)
        addRow(actionField, alignment: .fill)
        
        
        let interactionEnabledRow = createLabelAndSwitchRow(labelText: "Interaction Enabled", root: self, keyPath: \.interactionEnabled)
        addRow(interactionEnabledRow)
        
        let usesSharedHUDRow = createLabelAndSwitchRow(labelText: "Use Shared HUD", root: self, keyPath: \.usesSharedHUD)
        addRow(usesSharedHUDRow)
        
        let showButton = Button(designStyle: .primary, title: "Show HUD") { [weak self] _ in
            self?.showHUD()
        }
        addRow(showButton)        
    }
    
    private func updateContentType() {
        switch segmentIndex {
        case 1:
            if (hudText ?? "").trimmingWhitespacesAndAndNewlines().isEmpty {
                hudContentType = .text("Please input HUD text")
            } else {
                hudContentType = .text(hudText!)
            }
            
        default:
            if hudText?.isEmpty == true {
                hudContentType = .activity()
            } else {
                hudContentType = .activity(hudText)
            }
        }
    }
    
    private func showHUD() {
                        
        if usesSharedHUD {
            sharedHUDHideTimer?.stop()
            HUD.show(hudContentType, interactionEnabled: interactionEnabled, action: hudActionTitle != nil ? .init(title: hudActionTitle!, handler: { print("Action Triggered") }) : nil)
            
            sharedHUDHideTimer = .init(interval: 3, work: {
                HUD.hide()
            })
            sharedHUDHideTimer?.start()
        } else {
            hideTimer?.stop()
            hud.show(hudContentType, in: view, interactionEnabled: interactionEnabled, action: hudActionTitle != nil ? .init(title: hudActionTitle!, handler: { print("Action Triggered") }) : nil)
            
            hideTimer = .init(interval: 3, work: { [weak self] in
                self?.hud.hide()
            })
            hideTimer?.start()
        }
    
    }
    
}
