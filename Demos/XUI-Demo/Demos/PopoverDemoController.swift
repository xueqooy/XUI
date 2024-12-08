//
//  PopoverDemoController.swift
//  EDUI_Example
//
//  Created by 🌊 薛 on 2022/10/19.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XUI

class PopoverDemoController: DemoController {
    
    private enum ContentType: String, CaseIterable {
        case label = "Label"
        case form = "Form"
        case image = "Image"
        case controller = "Controller"
        
        var dismissMode: Popover.DismissMode {
            switch self {
            case .label, .image:
                return .tapOnSuperview
            case .form:
                return .none
            case .controller:
                return .tapOnOutsidePopover
            }
        }
    }
    
    private lazy var popover: Popover = {
        var config = Popover.Configuration()
        return Popover(configuration: config)
    }()
    
    private var contentType: ContentType = .label
    private var showsArrow: Bool = true
    private var limitsToBounds: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.background1
        
        let items: [SegmentControl.Item] = ContentType.allCases.map { type in
            .text(type.rawValue)
        }
        let segmentControl = SegmentControl(style: .toggle, items: items)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectionChanged = { [weak self] control in
            switch control.selectedSegmentIndex {
            case 0:
                self?.contentType = .label
            case 1:
                self?.contentType = .form
            case 2:
                self?.contentType = .image
            case 3:
                self?.contentType = .controller
            default:
                self?.contentType = .label
            }
        }
        addRow(segmentControl)
        
        
        addRow(createLabelAndSwitchRow(labelText: "Shows Arrow", isOn: true, switchAction: { [weak self] isOn in
            self?.showsArrow = isOn
        }))
        
        addRow(createLabelAndSwitchRow(labelText: "Limit to bounds", isOn: true, switchAction: { [weak self] isOn in
            self?.limitsToBounds = isOn
        }))
        
        addSpacer(300)
                
        addRow(InputField(placeholder: "Show Keyboard"))
        
        addRow(createButton(title: "Down popover") { [weak self] button in
            guard let self = self else {
                return
            }

            self.showPopover(from: button, preferredDirection: .down)
        })
        
        addRow(createButton(title: "Up popover") { [weak self] button in
            guard let self = self else {
                return
            }

            self.showPopover(from: button, preferredDirection: .up)
        })
               
        addRow(createButton(title: "From Leading popover") { [weak self] button in
            guard let self = self else {
                return
            }

            self.showPopover(from: button, preferredDirection: .fromLeading)
        }, alignment: .leading)
        
        addRow(createButton(title: "From Trailing popover") { [weak self] button in
            guard let self = self else {
                return
            }

            self.showPopover(from: button, preferredDirection: .fromTrailing)
        }, alignment: .trailing)

        addSpacer(1000)
    }

    private func showPopover(from anchorView: UIView, preferredDirection: Direction = .down) {
        var contentView: UIView?
        var contentController: UIViewController?
        
        switch contentType {
        case .label:
            let label = UILabel()
            label.numberOfLines = 0
            label.text = "You can show any content on popover, Such as label, form or image"
            
            contentView = label
        case .form:
            let formView = FormView()
            formView.itemSpacing = .XUI.spacing5
            formView.contentInset = .nondirectionalZero
//            formView.widthAnchor.constraint(equalToConstant: 270).isActive = true
            let input1 = InputField()
            input1.label = "Account"
            input1.placeholder = "Input your account"

            let input2 = PasswordInputField()
            input2.label = "Password"
            input2.placeholder = "Input your password"
            
            let input3 = PasswordInputField()
            input3.label = "Confirm Password"
            input3.placeholder = "Confirm your password"
            
            
            let confirmButton = Button(designStyle: .primary, title: "Confirm") { [weak self] _ in
                self?.popover.hide()
            }
            
            formView.addItem(FormRow(input1))
            formView.addItem(FormRow(input2))
            formView.addItem(FormRow(input3))
            formView.addItem(FormRow(confirmButton))

            contentView = formView
        case .image:
            let imageView = UIImageView(image: UIImage(named: "brand"))
            imageView.contentMode = .scaleAspectFit
            contentView = imageView
        
        case .controller:
            let controller = Demo.Drawer.viewController
            contentController = controller
        }
        
        popover.configuration.preferredDirection = preferredDirection
        popover.configuration.arrowSize = showsArrow ? Popover.Configuration().arrowSize : .zero
        popover.configuration.limitsToBounds = limitsToBounds
        popover.configuration.dismissMode = contentType.dismissMode
        
        if let contentView = contentView {
            popover.show(contentView, in: self.view, from: anchorView)
        } else if contentController != nil {
            let viewController = UIViewController()
            viewController.view.backgroundColor = .red
            viewController.preferredContentSize = CGSize(width: 100, height: 100)
            popover.show(viewController, in: self, from: anchorView)
        }
    }
}
