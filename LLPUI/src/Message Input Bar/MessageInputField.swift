//
//  MessageInputField.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/7.
//

import UIKit

public class MessageInputField: MultilineInputField  {
            
    public override var recommendedAdditionalHeight: CGFloat {
        if traitCollection.verticalSizeClass == .regular {
            return (UIScreen.main.bounds.height / 14).rounded(.down)
        } else {
            return (UIScreen.main.bounds.height / 27).rounded(.down)
        }
    }
    
    public override init() {
        super.init()

        boxStackView.alignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var defaultContentHeight: CGFloat {
        40.0
    }

}
