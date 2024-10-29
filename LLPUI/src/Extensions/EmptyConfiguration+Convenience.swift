//
//  EmptyConfiguration+Convenience.swift
//  LLPUI
//
//  Created by xueqooy on 2024/10/19.
//

import UIKit

public extension EmptyConfiguration {
    
    static func noRelevantContentFound() -> EmptyConfiguration {
        let text = Strings.noRelevantContentFound
        
        return if Device.current.isPhone && Device.current.orientation == .landscape {
            EmptyConfiguration(text: text, alignment: .top(offset: .LLPUI.spacing10 * 2))

        } else {
            EmptyConfiguration(image: Icons.warningWave, text: text, alignment: .top(offset: .LLPUI.spacing8))
        }
    }
    
    static func somethingWentWrong(refreshHandler: @escaping () -> Void) -> EmptyConfiguration {
        let text = Strings.somethingWentWrong
                
        let action = EmptyConfiguration.Action(title: Strings.refresh, handler: refreshHandler)
        
        return if Device.current.isPhone && Device.current.orientation == .landscape {
            EmptyConfiguration(text: text, alignment: .top(offset: .LLPUI.spacing10 * 2), action: action)

        } else {
            EmptyConfiguration(image: Icons.warningWave, text: text, alignment: .top(offset: .LLPUI.spacing8), action: action)
        }
    }
}
