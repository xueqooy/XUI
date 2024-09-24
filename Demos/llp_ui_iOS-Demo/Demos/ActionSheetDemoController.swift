//
//  ActionSheetDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/10/12.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI

class ActionSheetDemoController: DemoController {
        
    private enum CustomOptions: String, OptionGroupDefinition {
        
        var optionImage: UIImage? {
            switch self {
            case .lock:
                return UIImage(systemName: "lock")
            
            default:
                return nil
            }
        }
        
        var optionRichTitle: RichText? {
            switch self {
            case .lock:
                RichText.titleAndDetail("Lock after due date", "Lock this assignment after its due date")
            case .viewable:
                RichText("Viewable in gradebook")
            }
        }
        
        var optionType: LLPUI.OptionType {
            .checkbox
        }
        
        static var groupTitle: String? {
            "Assignment Options"
        }
        
        case lock
        case viewable
    }
        
    private var presentFromSourceView: Bool = true
    
    private lazy var customView: UIView = {
        let configuration = OptionMenuConfiguration(action: [], groupDefinitions: [CustomOptions.self])
        let view = OptionMenuView(configuration: configuration)
        view.configuration.stateDidChange
            .sink {
                print(configuration)
            }
            .store(in: &cancellables)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let presentLabelAndSwitch = createLabelAndSwitchRow(labelText: "Present Form Source View (iPad)", isOn: presentFromSourceView) { [weak self] isOn in
            self?.presentFromSourceView = isOn
        }
        
        let button = createButton(title: "Show Action Sheet") { [weak self] button in
            guard let self = self else { return }
            self.showActionSheet(sourceView: self.presentFromSourceView ? button : nil)
        }
        
        addRow(presentLabelAndSwitch)
        addSpacer()
        addRow(button)
    }
    
    private func showActionSheet(sourceView: UIView?) {
        let labelAndImageArray1: [(String, UIImage)] = [
            ("File form Library", Icons.library),
            ("Add Link", Icons.link),
        ]
        
        let labelAndImageArray2: [(String, UIImage)] = [
            ("Picture from Camera Roll", Icons.cameraRoll),
            ("Take Photo", Icons.camera),
            ("Add Sketch", Icons.sketch),
        ]
        
        ActionSheet(title: "Add Attachment") {
            for labelAndImage in labelAndImageArray1 {
                ASButton(title: labelAndImage.0, image: labelAndImage.1, handler: { print(labelAndImage.0) })
            }
            
            ASSeparator()
            
            ASLabel("Attachment")
            
            for labelAndImage in labelAndImageArray2 {
                ASButton(title: labelAndImage.0, image: labelAndImage.1, keepsSheetPresented: true, handler: { print(labelAndImage.0) })
            }
            
            ASSeparator()
            
            ASCustomView(customView)
        }
        .show(in: self, sourceView: sourceView)
    }
}
