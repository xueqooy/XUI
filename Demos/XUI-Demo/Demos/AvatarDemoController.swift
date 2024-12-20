//
//  AvatarDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/9/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI

class AvatarDemoController: DemoController {
    private let stepperLabel = UILabel(text: "No Limit", textColor: Colors.title, font: Fonts.body2Bold)

    private let oneAvatarGroupView = AvatarGroupView(avatarSize: .size24, urlConfigurations: [.init(preferredURL: .randomImageURL(width: 40, height: 40))])
    private let threeAvatarsGroupView = AvatarGroupView(avatarSize: .size24, urlConfigurations: [.init(preferredURL: .randomImageURL(width: 40, height: 40)), .init(preferredURL: .randomImageURL(width: 41, height: 41)), .init(preferredURL: .randomImageURL(width: 42, height: 42))])
    private let fiveAvatarsGroupView = AvatarGroupView(avatarSize: .size24, urlConfigurations: [.init(preferredURL: .randomImageURL(width: 40, height: 40)), .init(preferredURL: .randomImageURL(width: 41, height: 41)), .init(preferredURL: .randomImageURL(width: 42, height: 42)), .init(preferredURL: .randomImageURL(width: 43, height: 43)), .init(preferredURL: .randomImageURL(width: 44, height: 44))])

    override func viewDidLoad() {
        super.viewDidLoad()

        addTitle("Placeholder")
        let avatar = AvatarView(size: .size56) {
            print("Tapped")
        }
        addRow(avatar)

        let sizes: [AvatarSize] = [.size24, .size40, .size56]
        for siz in sizes {
            addTitle(siz.rawValue)
            let avatar = AvatarView(size: siz, urlConfiguration: .init(preferredURL: URL(string: "www.invalidImageURL.com"), alternativeURL: .randomImageURL(width: 80, height: 80))) {
                print("Tapped")
            }
            addRow(avatar)
        }

        addTitle("Avatar Group")

        addDescription("Maximum Number Of Displays")
        let stepper = UIStepper()
        stepper.addTarget(self, action: #selector(Self.stepperValueChanged(_:)), for: .valueChanged)
        addRow([stepperLabel, stepper], itemSpacing: .XUI.spacing5, alignment: .center)

        addDescription("1 Avatars")
        addRow(oneAvatarGroupView)

        addDescription("3 Avatars")
        addRow(threeAvatarsGroupView)

        addDescription("5 Avatars")
        addRow(fiveAvatarsGroupView)
    }

    @objc private func stepperValueChanged(_ sender: UIStepper) {
        let value = Int(sender.value)
        if value <= 0 {
            stepperLabel.text = "No Limit"
        } else {
            stepperLabel.text = String(value)
        }
        oneAvatarGroupView.maximumNumberOfDisplays = value
        threeAvatarsGroupView.maximumNumberOfDisplays = value
        fiveAvatarsGroupView.maximumNumberOfDisplays = value
    }
}
