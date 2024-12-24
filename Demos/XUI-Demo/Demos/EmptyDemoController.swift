//
//  EmptyDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/9/5.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XKit
import XUI

class EmptyDemoController: DemoController {
    private var emptyViewRow: FormRow!
    private var emptyViewWithDetailTextRow: FormRow!
    private var embbededFormRow: FormRow!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.background1

        let sliderView = UISlider()
        sliderView.minimumValue = 0
        sliderView.maximumValue = 500
        sliderView.value = 500
        sliderView.addTarget(self, action: #selector(Self.sliderValueChanged(_:)), for: .valueChanged)

        let emptyView = EmptyView(configuration: .init(text: "There are no feed for you"))

        let emptyViewWithDetailText = EmptyView(configuration: .init(image: Icons.quizColour, text: "No students have submiited this quiz yet.", detailText: "After at least one student submits this quiz, we’ll display quiz data here.", action: .init(title: "Add Students", handler: {
            print("Action Triggred")
        })))

        let items: [SegmentControl.Item] = ["Fill", "Centered Vertically"]
        let segmentControl = SegmentControl(style: .toggle, items: items)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectionChanged = { control in
            switch control.selectedSegmentIndex {
            case 1:
                emptyView.configuration.alignment = .centeredVertically()
                emptyViewWithDetailText.configuration.alignment = .centeredVertically()

            default:
                emptyView.configuration.alignment = .fill()
                emptyViewWithDetailText.configuration.alignment = .fill()
            }
        }
        addDescription("Alignment")
        addRow(segmentControl)
        addDescription("Height")
        addRow(sliderView, alignment: .fill)
        addSeparator()
        emptyViewRow = addRow(emptyView)
        addSeparator()
        emptyViewWithDetailTextRow = addRow(emptyViewWithDetailText)
        addSeparator()

        addTitle("Empty For Form")

        let formView = FormView()
        formView.backgroundConfiguration = .overlay()

        formView.emptyConfiguraiton = .init(text: "This is Empty Text", detailText: "This is empty detail text, long long long long long long long long long", alignment: .centeredVertically())

        let imageView = UIImageView(image: .init(named: "brand"), contentMode: .scaleAspectFit)
            .settingSizeConstraint(.square(60))
        let imageRow = FormRow(imageView, alignment: .center)

        formView.populate {
            FormSpacer(50)
            imageRow
        }

        let showContentSwitchRow = createLabelAndSwitchRow(labelText: "Show Content", isOn: true) { isOn in
            imageRow.isHidden = !isOn
        }
        addRow(showContentSwitchRow)
        embbededFormRow = addRow(formView, height: 200, alignment: .fill)
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        let value = sender.value

        emptyViewRow.heightMode = .fixed(CGFloat(value))
        emptyViewWithDetailTextRow.heightMode = .fixed(CGFloat(value))
        embbededFormRow.heightMode = .fixed(CGFloat(value))
    }
}
