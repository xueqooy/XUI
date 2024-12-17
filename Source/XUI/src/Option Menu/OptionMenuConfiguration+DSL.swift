//
//  OptionsObject+DSL.swift
//  XUI
//
//  Created by xueqooy on 2024/4/7.
//

import Foundation
import XKit


public extension OptionGroup {
    
    init(title: String? = nil, @ArrayBuilder<Option> options: () -> [Option]) {
        self.init(title: title, options: options())
    }
    
    init(title: String? = nil, @ArrayBuilder<any OptionDefinition> optionDefinitions: () -> [any OptionDefinition]) {
        self.init(title: title, optionDefinitions: optionDefinitions())
    }
}

public extension OptionMenuConfiguration {
    
    convenience init(title: String? = nil, action: Action = [], @ArrayBuilder<OptionGroup> groups: () -> [OptionGroup]) {
        self.init(title: title, action: action, groups: groups())
    }
    
    convenience init(title: String? = nil, action: Action = [], @ArrayBuilder<any OptionGroupDefinition.Type> groupDefinitions: () -> [any OptionGroupDefinition.Type]) {
        self.init(title: title, action: action, groupDefinitions: groupDefinitions())
    }
}
