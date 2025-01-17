//
//  OptionMenu.swift
//  XUI
//
//  Created by xueqooy on 2024/4/8.
//

import Foundation
import UIKit

/**
 Options menu, including checkmark, checkbox, radio, switch and supports grouping

 ```
 let configuration = OptionMenuConfiguration(title: "Sort") {
     OptionGroup {
         Option(id: "latestPosts", title: "Latest Posts", type: .radio)
         Option(id: "latestActivities", title: "Latest Activities", type: .radio)
     }
 }

 let menu = OptionMenu(configuration: configuration, presentationStyle: .drawer, presentingViewController: presentingViewController, sourceView: sourceView)

 menu.activate()

 ```
 */
public class OptionMenu: ContentPresenter {
    public let configuration: OptionMenuConfiguration

    public init(configuration: OptionMenuConfiguration, presentationStyle: PresentationStyle, presentingViewController: UIViewController? = nil, sourceView: UIView? = nil, sourceRect: CGRect? = nil) {
        self.configuration = configuration

        super.init(presentationStyle: presentationStyle)

        self.presentingViewController = presentingViewController
        self.sourceView = sourceView
        self.sourceRect = sourceRect
    }

    override public var contentView: UIView? {
        let view = OptionMenuView(configuration: configuration)
        view.applyButtonDidTap = {
            self.deactivate()
        }
        return view
    }

    override public var popoverConfiguration: Popover.Configuration {
        var configuration = Popover.Configuration()
        configuration.preferredDirection = .down
        configuration.dismissMode = .tapOnOutsidePopoverAndAnchor
        return configuration
    }

    override public var popupConfiguration: PopupController.Configuration {
        .init(cancelAction: nil)
    }

    override public var preferredContentSize: CGSize? {
        CGSize(width: 375, height: 0)
    }
}
