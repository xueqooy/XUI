//
//  RangeSliderLayer.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/23.
//

import UIKit

class RangeSliderLayer: CALayer {
    
    private static let animationKeyPaths = ["position", "bounds", "contents"]
    
    var isAnimationEnabled: Bool = false

    override init() {
        super.init()
        
        contentsScale = UIScreen.main.scale
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        
        contentsScale = UIScreen.main.scale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func defaultAction(forKey event: String) -> CAAction? {
        var action = super.defaultAction(forKey: event)
        
        // Modify default animations
        if Self.animationKeyPaths.contains(event) {
            let animation = CABasicAnimation(keyPath: event)
            animation.duration = 0.12
            action = animation
        }
        
        return action
    }
    
    override func action(forKey event: String) -> CAAction? {
        if isAnimationEnabled {
            return super.action(forKey: event)
        } else {
            return nil
        }
    }
    
}
