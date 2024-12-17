//
//  DisplayLinkAnimator.swift
//  XUI
//
//  Created by xueqooy on 2024/5/17.
//

import UIKit

private final class DisplayLinkTarget: NSObject {
    
    private let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    @objc func trigger() {
        self.action()
    }
}

public final class DisplayLinkAnimator {
    
    private var displayLink: CADisplayLink!
    private let duration: TimeInterval
    private let fromValue: CGFloat
    private let toValue: CGFloat
    private let startTime: TimeInterval
    private let update: (CGFloat) -> Void
    private let completion: (() -> Void)?
    private var completed = false
    
    public init(duration: TimeInterval, from fromValue: CGFloat, to toValue: CGFloat, update: @escaping (CGFloat) -> Void, completion: (() -> Void)? = nil) {
        self.duration = duration
        self.fromValue = fromValue
        self.toValue = toValue
        self.update = update
        self.completion = completion
        
        startTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: DisplayLinkTarget({ [weak self] in
            self?.tick()
        }), selector: #selector(DisplayLinkTarget.trigger))
        displayLink.isPaused = false
        displayLink.add(to: RunLoop.main, forMode: .common)
    }
    
    deinit {
        displayLink.isPaused = true
        displayLink.invalidate()
    }
    
    public func invalidate() {
        displayLink.isPaused = true
        displayLink.invalidate()
    }
    
    @objc private func tick() {
        if completed {
            return
        }
        
        let timestamp = CACurrentMediaTime()
        var t = (timestamp - startTime) / duration
        t = max(0.0, t)
        t = min(1.0, t)
        update(fromValue * CGFloat(1 - t) + toValue * CGFloat(t))
        if abs(t - 1.0) < Double.ulpOfOne {
            completed = true
            invalidate()
            completion?()
        }
    }
}
