//
//  DropdownMenu+DSL.swift
//  XUI
//
//  Created by xueqooy on 2024/5/7.
//

import UIKit
import XKit

public func DMAction(title: String, identifier: String? = nil, state: DropdownMenu.Action.State, handler: @escaping DropdownMenu.Action.Handler) -> DropdownMenu.Action {
    DropdownMenu.Action(title: title, identifier: identifier, state: state, handler: handler)
}

public extension DropdownMenu {
    convenience init(preference: Preference = .init(), @ArrayBuilder<Action> actions: () -> [Action]) {
        self.init(preference: preference, actions: actions())
    }
}
