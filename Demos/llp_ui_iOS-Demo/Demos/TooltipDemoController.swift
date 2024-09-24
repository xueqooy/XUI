//
//  TooltipDemoController.swift
//  EDUI_Example
//
//  Created by 🌊 薛 on 2022/9/21.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import LLPUI

class TooltipDemoController: DemoController {
    
    private enum ContentType: String, CaseIterable {
        case normal = "Normal"
        case link = "Link"
        case taggedLink = "Tagged Link"
    }
    
    private var contentType: ContentType = .normal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items: [SegmentControl.Item] = ContentType.allCases.map { type in
            .text(type.rawValue)
        }
        let segmentControl = SegmentControl(style: .toggle, items: items)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectionChanged = { [weak self] control in
            switch control.selectedSegmentIndex {
            case 0:
                self?.contentType = .normal
            case 1:
                self?.contentType = .link
            case 2:
                self?.contentType = .taggedLink
            default:
                break
            }
        }
        addRow(segmentControl)
                
        [(Direction.down, "Down tooltip", RowAlignment.center), (Direction.up, "Up tooltip", RowAlignment.center), (Direction.fromLeading, "From Leading tooltip", RowAlignment.leading), (Direction.fromTrailing, "From Trailing tooltip", RowAlignment.trailing)]
            .forEach { directionAndTitleAndDirection in
                addRow(createButton(title: directionAndTitleAndDirection.1) { [weak self] button in
                    guard let self = self else {
                        return
                    }
                    
                    self.presentTooltip(from: button, preferredDirection: directionAndTitleAndDirection.0)
                }, alignment: directionAndTitleAndDirection.2)
            }
    }
    
    let tooltip = Tooltip()

    private func presentTooltip(from anchorView: UIView, preferredDirection: Direction = .down) {
        tooltip.configuration.preferredDirection = preferredDirection
        switch contentType {
        case .normal:
            tooltip.show("This a tooltip with normal message", from: anchorView)
        case .link:
            tooltip.show("This a tooltip with link message", links: ["link"], from: anchorView) { [weak self] link in
                self?.showMessage(link)
            }
        case .taggedLink:
            tooltip.show("This a tooltip with ##tagged link## message", linkTags: ["##"], from: anchorView) { [weak self] (link, tag) in
                self?.showMessage("\(link), tag: \(tag)")
            }
        }
        
    }
}
