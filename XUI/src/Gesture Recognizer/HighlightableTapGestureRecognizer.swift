//
//  HighlightableTapGestureRecognizer.swift
//  XUI
//
//  Created by xueqooy on 2023/9/13.
//

import UIKit

public class HighlightableTapGestureRecognizer: UITapGestureRecognizer {
    
    public static let defaultHighlightChangedImpl: (Bool, UIView?) -> Void = { isHighlighted, view in
        if let view = view {
            if isHighlighted {
                view.layer.removeAnimation(forKey: "opacity")
                view.alpha = .XUI.highlightAlpha
            } else {
                view.alpha = 1.0
                view.layer.animateAlpha(from: .XUI.highlightAlpha, to: 1.0, duration: 0.2)
            }
        }
    }
    
    private var isHighlighted = false
        
    public var highlightChanged: (Bool, UIView?) -> Void = defaultHighlightChangedImpl

    public override func reset() {
        super.reset()
        
        if isHighlighted {
            isHighlighted = false
            highlightChanged(false, self.view)
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if !isHighlighted {
            isHighlighted = true
            highlightChanged(true, self.view)
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        if isHighlighted {
            isHighlighted = false
            highlightChanged(false, self.view)
        }
        
        super.touchesCancelled(touches, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if isHighlighted {
            isHighlighted = false
            highlightChanged(false, self.view)
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if isHighlighted {
            isHighlighted = false
            highlightChanged(false, self.view)
        }
        
        super.touchesMoved(touches, with: event)
    }
}

