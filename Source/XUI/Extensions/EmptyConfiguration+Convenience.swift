//
//  EmptyConfiguration+Convenience.swift
//  XUI
//
//  Created by xueqooy on 2024/10/19.
//

import UIKit

public extension EmptyConfiguration {
    static func deviceAdaptation(image: @autoclosure () -> UIImage? = nil, text: String? = nil, detailText: String? = nil, action: Action? = nil) -> EmptyConfiguration {
        return if Device.current.isPhone && Device.current.orientation == .landscape {
            EmptyConfiguration(image: image(), text: text, detailText: detailText, alignment: .top(offset: .XUI.spacing10 * 2), action: action)

        } else {
            EmptyConfiguration(image: image(), text: text, detailText: detailText, alignment: .top(offset: .XUI.spacing8), action: action)
        }
    }

    static func noRelevantContentFound() -> EmptyConfiguration {
        deviceAdaptation(image: Icons.warningWave, text: Strings.noRelevantContentFound)
    }

    static func somethingWentWrong(refreshHandler: @escaping () -> Void) -> EmptyConfiguration {
        let action = EmptyConfiguration.Action(title: Strings.refresh, handler: refreshHandler)

        return deviceAdaptation(image: Icons.warningWave, text: Strings.somethingWentWrong, action: action)
    }
}
