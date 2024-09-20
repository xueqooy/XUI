//
//  CoachmarkGenericContentView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/5.
//

import UIKit

public class CoachmarkGenericContentView: UIView {
    public init(currentStep: Int, totalSteps: Int, instruction: String, controller: CoachmarkController) {
        super.init(frame: .zero)
                
        let isLastStep = currentStep >= totalSteps - 1
        
        let stepLabel = UILabel(text: Strings.step(currentStep + 1, of: totalSteps), textColor: Colors.title, font: Fonts.body1)
        
        let instructionLabel = UILabel(text: instruction, textColor: Colors.title, font: Fonts.body2, numberOfLines: 0)
        instructionLabel.preferredMaxLayoutWidth = 270
        
        let nextButton = Button(designStyle: .primarySmall, title: isLastStep ? Strings.done : Strings.next) { [weak controller] _ in
            guard let controller = controller else { return }
            controller.next()
        }
     
        let skipLabel: LinkedLabel? = isLastStep ? nil : {
            let label = LinkedLabel()
            label.linkFont = Fonts.button1
            label.set(text: Strings.skip, links: [Strings.skip])
            label.didTap = { [weak controller] _ in
                guard let controller = controller else { return }
                controller.stop()
            }
            return label
        }()
        
        addForm { formView in
            formView.contentInset = .nondirectionalZero
            formView.itemSpacing = .zero
        } populate: {
            FormRow(stepLabel)
            FormSpacer(.LLPUI.spacing3)
            FormRow(instructionLabel)
            FormSpacer(.LLPUI.spacing4)
            if let skipLabel = skipLabel {
                FormRow([nextButton, SpacerView(.LLPUI.spacing5, compressionResistancePriority: .required), skipLabel, SpacerView.flexible()])
            } else {
                FormRow([nextButton, SpacerView.flexible()])
            }
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
