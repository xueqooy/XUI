//
//  CustomButtonConfigurationTransformer.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/31.
//

import UIKit

public class CustomButtonConfigurationTransformer: PlainButtonConfigurationTransformer {
    
    private let customizer: (inout ButtonConfiguration, Button) -> Void
    
    public init(_ customizer: @escaping (inout ButtonConfiguration, Button) -> Void) {
        self.customizer = customizer
        
        super.init()
    }
    
    public override func update(_ configuration: inout ButtonConfiguration, for button: Button) {
        customizer(&configuration, button)
        
        super.update(&configuration, for: button)
    }
}
