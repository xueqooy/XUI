//
//  FormScrollView.swift
//  XUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit
import Combine

public class FormScrollView: UIScrollView {
        
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {       
        contentInsetAdjustmentBehavior = .never
        
        automaticallyAdjustsBottomInsetBasedOnKeyboardHeight = true
        makesFirstResponderVisibleWhenKeyboardHeightChange = true
    }
}
