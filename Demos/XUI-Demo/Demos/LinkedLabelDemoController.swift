//
//  LinkedLabelDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/2/22.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XKit
import XUI

class LinkedLabelDemoController: DemoController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let onlyLinkLabel = createLabel()
        onlyLinkLabel.set(text: "Forget Password?", links: ["Forget Password?"])

        let mixedLabel = createLabel()
        mixedLabel.set(text: "Don't have an account? Sign Up", links: ["Sign Up"])

        let mixedDoubleLinkLabel = createLabel()
        mixedDoubleLinkLabel.set(text: "HERE and THERE", links: ["HERE", "THERE"])

        let multipleLineLinkLabel = createLabel()
        multipleLineLinkLabel.set(text: "Connect to tools you use everyday; like Jira, Slack, Microsoft Teams, Trello and Storybook.", links: ["Jira", "Slack", "Microsoft Teams", "Trello", "Storybook"])

        let longLinkLabel = createLabel()
        longLinkLabel.set(text: "Components are interactive building blocks for creating a user interface.A number of UI components are available in this list for layouts, grids, buttons, form elements, and more. Every component in the site should be aligned and with the list provided.", links: ["building blocks for creating a user interface.A number of UI components are available in this list for layouts, grids, buttons, form elements, and more", "aligned"])

        let tagLinkLabel = createLabel()
        tagLinkLabel.set(text: "Components are interactive #building blocks for creating a user interface.A number of UI components are available in this list for layouts, grids, buttons, form elements, and more#. Every component in the site should be #aligned# and with the list provided.", linkTags: ["#"])

        let doubleTagLinkLabel = createLabel()
        doubleTagLinkLabel.set(text: "By logging in, you agree to our ##Terms of Service## and **Privacy Policy**.", linkTags: ["##", "**"])

        // Will trigger assert
//        let notAllowedLinkLabel = createLabel()
//        notAllowedLinkLabel.set(text: "I will not ##desert## my dessert in the **desert**.", linkTags: ["##", "**"], actionForTag: {_ in })

        addRow(onlyLinkLabel)
        addRow(mixedLabel)
        addRow(mixedDoubleLinkLabel)
        addRow(multipleLineLinkLabel)
        addRow(longLinkLabel)
        addRow(tagLinkLabel)
        addRow(doubleTagLinkLabel)
    }

    private func createLabel() -> LinkedLabel {
        let label = LinkedLabel()
        label.didTapPublisher
            .sink { [weak self] linkAndTag in
                if let link = linkAndTag?.0 {
                    self?.showMessage("\(link), tag: \(linkAndTag?.1 ?? "nil")")
                } else {
                    Logs.info("Tap place outside link", tag: "LinkedLabel Demo")
                }
            }
            .store(in: &cancellables)
        return label
    }
}
