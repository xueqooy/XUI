//
//  IconsDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/10/17.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI

class IconsDemoController: DemoController {
    
    var allImageViews = [UIImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRow(createLabelAndSwitchRow(labelText: "With Purple Tint Color", isOn: false, switchAction: { [unowned self] isOn in
            self.allImageViews.forEach { $0.tintColor = isOn ? Colors.teal: nil }
        }))
        
        let allSmallIcons: [UIImage] = [
            // 0
            Icons.dropdown,
            Icons.calendar,
            Icons.visibilityOff,
            Icons.visibilityOn,
            Icons.checkboxOn,
            Icons.checkmark,
            Icons.radioOn,
            Icons.search,
            Icons.arrowRight,
            Icons.filter,
            Icons.sort,
            Icons.camera,
            Icons.notification,
            Icons.document,
            Icons.link,
            Icons.video,
            Icons.more,
            Icons.gif,
            Icons.attachment,
            Icons.mediaGoogleDoc,
            Icons.mediaGoogleSheet,
            Icons.mediaGoogleSlide,
            Icons.mediaExcel,
            Icons.mediaPPT,
            Icons.mediaWord,
            Icons.mediaPDF,
            Icons.mediaZip,
            Icons.mediaLink,
            Icons.mediaDocument,
            Icons.mediaVideo,
            Icons.trashColour,
            Icons.library,
            Icons.sketch,
            Icons.cameraRoll,
            Icons.likeActive,
            Icons.likeDeactive,
            Icons.comment,
            Icons.share,
            Icons.trash,
            Icons.edit,
            Icons.backpack,
            Icons.assignment,
            Icons.mediaUnknown,
            Icons.group,
            Icons.message,
            Icons.pollColour,
            Icons.quizColour,
            Icons.eventColour,
            Icons.assignmentColour,
            Icons.wellnessCheckColour
        ]
        
        let allLargeIcons: [UIImage] = [
            Icons.avatarPlaceholder
        ]
        
        addSeparator()
        addTitle("Small Icons")
        
        let countPerRow = 4
        for i in stride(from: 0, to: allSmallIcons.count, by: countPerRow) {
            let endIndex = min(i + countPerRow, allSmallIcons.count)
            let smallIconGroup = Array(allSmallIcons[i..<endIndex])
            
            let views = smallIconGroup.map { smallIcon in
                createImageView(with: smallIcon)
            }
            
            addDescription("\(i)")
            addRow(views, itemSpacing: .XUI.spacing10, alignment: .center, distribution: .equalCentering)
        }
        
        addSeparator()
        addTitle("Big Icons")
        
        for largeIcon in allLargeIcons {
            addRow(createImageView(with: largeIcon), alignment: .center)
        }
    }
    
    func createImageView(with icon: UIImage) -> UIImageView {
        let imageView = UIImageView(image: icon, contentMode: .scaleAspectFit)
        allImageViews.append(imageView)
        return imageView
    }
}
