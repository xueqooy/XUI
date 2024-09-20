//
//  ProgressiveGestureRecognizer.swift
//  LLPUI
//
//  Created by xueqooy on 2024/6/7.
//

import UIKit
import Combine
import LLPUtils

public class ProgressivePressGestureRecognizer: UIGestureRecognizer {
    
    @EquatableState
    public private(set) var progress: CGFloat = 0 {
        didSet {
            progressChanged?(progress)
        }
    }
     
    private let maxPressDuration: TimeInterval
    
    private let resetDuration: TimeInterval
    
    private var animator: DisplayLinkAnimator?
    
    private let progressChanged: ((CGFloat) -> Void)?
    
    
    public init(maxPressDuration: TimeInterval, resetDuration: TimeInterval, progressChanged: ((CGFloat) -> Void)? = nil) {
        self.maxPressDuration = max(0, maxPressDuration)
        self.resetDuration = max(0, resetDuration)
        self.progressChanged = progressChanged
        
        super.init(target: nil, action: nil)
        
        self.cancelsTouchesInView = false
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        guard touches.count == 1 else {
            self.state = .failed
            return
        }
        
        animator = nil
                
        if maxPressDuration > 0 {
            let duration = (1.0 - progress) * maxPressDuration
            
            animator = DisplayLinkAnimator(duration: duration, from: progress, to: 1, update: { [weak self] value in
                guard let self else { return }
                
                self.progress = value
            })
        } else {
            progress = 1
        }
        
        state = .began
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        guard touches.first != nil else {
            state = .failed
            return
        }
        
        state = .changed
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        resetProgress()
        
        state = .ended
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
                
        resetProgress()
        
        state = .cancelled
    }
    
    private func resetProgress() {
        animator = nil
        
        if resetDuration > 0 {
            let duration = progress * resetDuration
            
            animator = DisplayLinkAnimator(duration: duration, from: progress, to: 0, update: { [weak self] value in
                guard let self else { return }
                
                self.progress = value
              
            }, completion: {  [weak self] in
                guard let self else { return }
                
                progress = 0
            })
        } else {
            progress = 0
        }
    }
    
}
