//
//  CoachmarkWindow.swift
//  LLPUI
//
//  Created by xueqooy on 2023/7/28.
//

import UIKit

class CoachmarkWindow: UIWindow {
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {
        windowLevel = .normal + 1
    }
}
