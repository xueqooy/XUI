//
//  OptionControlDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/3/8.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI

class OptionControlDemoController: DemoController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitle("Checkbox")
        
        func handleRichTextAction() {
            print("Rich text action")
        }
        
        let checkbox1 = createOptionControl(style: .checkbox, titlePlacement: .leading)
        addRow(checkbox1, alignment: .center)
        
        let checkbox2 = createOptionControl(style: .checkbox, titlePlacement: .leading, title: "Checkbox with leading label")
        addRow(checkbox2, alignment: .leading)
        
        let checkbox3 = createOptionControl(style: .checkbox, titlePlacement: .trailing, title: "Checkbox with trailing")
        addRow(checkbox3, alignment: .leading)
        
        let checkbox4 = createOptionControl(style: .checkbox, titlePlacement: .trailing, title: "Disabled Checkbox", enabled: false)
        addRow(checkbox4, alignment: .leading)
        
        let checkbox5 = createOptionControl(style: .checkbox, titlePlacement: .trailing, richTitle: "Checkbox with \("Rich Text", .foreground(Colors.mediumTeal), .action(handleRichTextAction))", enabled: true)
        addRow(checkbox5, alignment: .leading)
        
        let checkbox6 = createOptionControl(style: .checkbox, titlePlacement: .trailing, title: "Checkbox with long long long long long long long long long long long long long long text")
        addRow(checkbox6, alignment: .leading)
        
        addTitle("Checkmark")
        
        let checkmark1 = createOptionControl(style: .checkmark, titlePlacement: .leading, image: Icons.verticalBar)
        addRow(checkmark1, alignment: .center)
        
        let checkmark2 = createOptionControl(style: .checkmark, titlePlacement: .leading, title: "Checkmark with leading label")
        addRow(checkmark2, alignment: .fill)
        
        let checkmark3 = createOptionControl(style: .checkmark, titlePlacement: .trailing, title: "Checkmark with trailing label")
        addRow(checkmark3, alignment: .fill)
        
        let checkmark4 = createOptionControl(style: .checkmark, titlePlacement: .leading, title: "Disabled Checkmark", enabled: false)
        addRow(checkmark4, alignment: .fill)
        
        
        addTitle("Radio")

        let radio1 = createOptionControl(style: .radio, titlePlacement: .leading)
        addRow(radio1, alignment: .center)
        
        let radio2 = createOptionControl(style: .radio, titlePlacement: .leading, title: "Radio with leading label")
        addRow(radio2, alignment: .leading)
        
        let radio3 = createOptionControl(style: .radio, titlePlacement: .trailing, title: "Radio with trailing label", enabled: false)
        addRow(radio3, alignment: .leading)
        
        let radio4 = createOptionControl(style: .radio, titlePlacement: .trailing, title: "Disabled Radio", enabled: false)
        addRow(radio4, alignment: .leading)
        
        
        addTitle("Switch")
        
        let radioGroup = SingleSelectionGroup()

        let switch1 = createOptionControl(style: .switch, titlePlacement: .leading)
        addRow(switch1, alignment: .center)
        
        let switch2 = createOptionControl(style: .switch, titlePlacement: .leading, title: "Switch with leading label")
        addRow(switch2, alignment: .fill)
        
        let switch3 = createOptionControl(style: .switch, titlePlacement: .trailing, title: "Switch with trailing label")
        addRow(switch3, alignment: .fill)
        
        let switch4 = createOptionControl(style: .switch, titlePlacement: .leading, title: "Disabled Switch", enabled: false)
        addRow(switch4, alignment: .fill)
        

        addTitle("Radio Group")
                    
        let radio5 = createOptionControl(style: .radio, titlePlacement: .trailing, title: "Radio A", radioGroup: radioGroup)
        addRow(radio5, alignment: .leading)
        
        let radio6 = createOptionControl(style: .radio, titlePlacement: .trailing, title: "Radio B", radioGroup: radioGroup)
        addRow(radio6, alignment: .leading)
        
        let radio7 = createOptionControl(style: .radio, titlePlacement: .trailing, title: "Radio C", radioGroup: radioGroup)
        addRow(radio7, alignment: .leading)
    }
    
    private func createOptionControl(style: OptionControl.Style, titlePlacement: OptionControl.TitlePlacement, alignment: OptionControl.Alignment = .center, title: String? = nil, richTitle: RichText? = nil, image: UIImage? = nil, enabled: Bool = true, radioGroup: SingleSelectionGroup? = nil) -> OptionControl {
        let optionControl = OptionControl(style: style, titlePlacement: titlePlacement, alignment: alignment)
        if let title = title {
            optionControl.title = title
        } else if let richTitle = richTitle {
            optionControl.richTitle = richTitle
        }
        
        if let image = image {
            optionControl.image = image
        }
        
        optionControl.isEnabled = enabled
        optionControl.singleSelectionGroup = radioGroup
        optionControl.addTarget(self, action: #selector(Self.controlSelectionStateChanged(_:)), for: .valueChanged)
        
        return optionControl
    }
    
    @objc private func controlSelectionStateChanged(_ sender: OptionControl) {
        print("\(sender.title ?? "") -> \(sender.isSelected)")
    }
}
