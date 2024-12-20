//
//  CALayer+Animations.swift
//  XUI
//
//  Created by xueqooy on 2023/3/8.
//

import UIKit

private class AnimationDelegate: NSObject, CAAnimationDelegate {
    private let keyPath: String?
    var completion: ((Bool) -> Void)?

    init(animation: CAAnimation, completion: ((Bool) -> Void)?) {
        if let animation = animation as? CABasicAnimation {
            keyPath = animation.keyPath
        } else {
            keyPath = nil
        }
        self.completion = completion

        super.init()
    }

    @objc func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let anim = anim as? CABasicAnimation {
            if anim.keyPath != keyPath {
                return
            }
        }
        if let completion = completion {
            completion(flag)
            self.completion = nil
        }
    }
}

public extension CAAnimation {
    var completion: ((Bool) -> Void)? {
        get {
            if let delegate = delegate as? AnimationDelegate {
                return delegate.completion
            } else {
                return nil
            }
        } set(value) {
            if let delegate = delegate as? AnimationDelegate {
                delegate.completion = value
            } else {
                delegate = AnimationDelegate(animation: self, completion: value)
            }
        }
    }

    static func springAnimation(_ keyPath: String) -> CASpringAnimation {
        let springAnimation = CASpringAnimation(keyPath: keyPath)
        springAnimation.mass = 3
        springAnimation.stiffness = 1000
        springAnimation.damping = 500
        springAnimation.duration = 0.5
        springAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        return springAnimation
    }

    static func springBounceAnimation(_ keyPath: String, initialVelocity: CGFloat, damping: CGFloat) -> CASpringAnimation {
        let springAnimation = CASpringAnimation(keyPath: keyPath)
        springAnimation.mass = 5
        springAnimation.stiffness = 900
        springAnimation.damping = damping
        springAnimation.initialVelocity = initialVelocity
        springAnimation.duration = springAnimation.settlingDuration
        springAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        return springAnimation
    }

    fileprivate static var animationDurationFactor: CGFloat {
        1.0
    }

    fileprivate func adjustFrameRate() {
        if #available(iOS 15.0, *) {
            let maxFps = Float(UIScreen.main.maximumFramesPerSecond)
            if maxFps > 61.0 {
                preferredFrameRateRange = CAFrameRateRange(minimum: maxFps, maximum: maxFps, preferred: maxFps)
            }
        }
    }
}

public enum AnimationTimingFunction {
    case linear, easeIn, easeOut, easeInEaseOut, `default` // System presets
    case caMediaTimingFunction(_ function: CAMediaTimingFunction)
    case spring
    case customSpring(damping: CGFloat, initialVelocity: CGFloat)
}

public extension CALayer {
    func makeAnimation(from: AnyObject? = nil, to: AnyObject, keyPath: String, timingFunction: AnimationTimingFunction = .easeInEaseOut, duration: Double, delay: Double = 0.0, removeOnCompletion: Bool = true, additive: Bool = false, completion: ((Bool) -> Void)? = nil) -> CAAnimation {
        var mediaTimingFunction: CAMediaTimingFunction?
        switch timingFunction {
        case .linear:
            mediaTimingFunction = CAMediaTimingFunction(name: .linear)
        case .easeIn:
            mediaTimingFunction = CAMediaTimingFunction(name: .easeIn)
        case .easeOut:
            mediaTimingFunction = CAMediaTimingFunction(name: .easeOut)
        case .easeInEaseOut:
            mediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        case .default:
            mediaTimingFunction = CAMediaTimingFunction(name: .default)
        case let .caMediaTimingFunction(function):
            mediaTimingFunction = function
        case .spring:
            let animation = CAAnimation.springAnimation(keyPath)
            animation.fromValue = from
            animation.toValue = to
            animation.isRemovedOnCompletion = removeOnCompletion
            animation.fillMode = .forwards
            if let completion = completion {
                animation.delegate = AnimationDelegate(animation: animation, completion: completion)
            }

            let k = Float(CAAnimation.animationDurationFactor)
            var speed: Float = 1.0
            if k != 0 && k != 1 {
                speed = Float(1.0) / k
            }

            animation.speed = speed * Float(animation.duration / duration)
            animation.isAdditive = additive

            if !delay.isZero {
                animation.beginTime = convertTime(CACurrentMediaTime(), from: nil) + delay * CAAnimation.animationDurationFactor
                animation.fillMode = .both
            }

            animation.adjustFrameRate()

            return animation
        case let .customSpring(damping, initialVelocity):
            let animation = CASpringAnimation(keyPath: keyPath)
            animation.fromValue = from
            animation.toValue = to
            animation.isRemovedOnCompletion = removeOnCompletion
            animation.fillMode = .forwards
            if let completion = completion {
                animation.delegate = AnimationDelegate(animation: animation, completion: completion)
            }
            animation.damping = CGFloat(damping)
            animation.initialVelocity = CGFloat(initialVelocity)
            animation.mass = 5.0
            animation.stiffness = 900.0
            animation.duration = animation.settlingDuration
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            let k = Float(CAAnimation.animationDurationFactor)
            var speed: Float = 1.0
            if k != 0 && k != 1 {
                speed = Float(1.0) / k
            }
            animation.speed = speed * Float(animation.duration / duration)
            animation.isAdditive = additive
            if !delay.isZero {
                animation.beginTime = convertTime(CACurrentMediaTime(), from: nil) + delay * CAAnimation.animationDurationFactor
                animation.fillMode = .both
            }
            animation.adjustFrameRate()

            return animation
        }

        let k = Float(CAAnimation.animationDurationFactor)
        var speed: Float = 1.0
        if k != 0 && k != 1 {
            speed = Float(1.0) / k
        }

        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.timingFunction = mediaTimingFunction
        animation.isRemovedOnCompletion = removeOnCompletion
        animation.fillMode = .forwards
        animation.speed = speed
        animation.isAdditive = additive
        if let completion = completion {
            animation.delegate = AnimationDelegate(animation: animation, completion: completion)
        }

        if !delay.isZero {
            animation.beginTime = convertTime(CACurrentMediaTime(), from: nil) + delay * CAAnimation.animationDurationFactor
            animation.fillMode = .both
        }

        animation.adjustFrameRate()

        return animation
    }

    func animate(from: AnyObject?, to: AnyObject, keyPath: String, timingFunction: AnimationTimingFunction = .easeInEaseOut, duration: Double, delay: Double = 0.0, removeOnCompletion: Bool = true, additive: Bool = false, completion: ((Bool) -> Void)? = nil) {
        let animation = makeAnimation(from: from, to: to, keyPath: keyPath, timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, additive: additive, completion: completion)
        add(animation, forKey: additive ? nil : keyPath)
    }

    func animateGroup(_ animations: [CAAnimation], key: String, completion: ((Bool) -> Void)? = nil) {
        let animationGroup = CAAnimationGroup()
        var timeOffset = 0.0
        for animation in animations {
            animation.beginTime = convertTime(animation.beginTime, from: nil) + timeOffset
            timeOffset += animation.duration / Double(animation.speed)
        }
        animationGroup.animations = animations
        animationGroup.duration = timeOffset
        if let completion = completion {
            animationGroup.delegate = AnimationDelegate(animation: animationGroup, completion: completion)
        }

        add(animationGroup, forKey: key)
    }

    func animateKeyframes(values: [AnyObject], duration: Double, keyPath: String, mediaTimingFunctions: [CAMediaTimingFunction]? = nil, removeOnCompletion: Bool = true, additive: Bool = false, completion: ((Bool) -> Void)? = nil) {
        let k = Float(CAAnimation.animationDurationFactor)
        var speed: Float = 1.0
        if k != 0, k != 1 {
            speed = Float(1.0) / k
        }

        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.values = values
        var keyTimes: [NSNumber] = []
        for i in 0 ..< values.count {
            if i == 0 {
                keyTimes.append(0.0)
            } else if i == values.count - 1 {
                keyTimes.append(1.0)
            } else {
                keyTimes.append((Double(i) / Double(values.count - 1)) as NSNumber)
            }
        }
        animation.keyTimes = keyTimes
        animation.speed = speed
        animation.duration = duration
        animation.isAdditive = additive
        if let mediaTimingFunctions, !mediaTimingFunctions.isEmpty {
            animation.timingFunctions = mediaTimingFunctions
        }
        animation.isRemovedOnCompletion = removeOnCompletion
        if let completion = completion {
            animation.delegate = AnimationDelegate(animation: animation, completion: completion)
        }

        animation.adjustFrameRate()

        add(animation, forKey: keyPath)
    }

    func animateSpring(from: AnyObject? = nil, to: AnyObject, keyPath: String, duration: Double, delay: Double = 0.0, initialVelocity: CGFloat = 0.0, damping: CGFloat = 88.0, removeOnCompletion: Bool = true, additive: Bool = false, completion: ((Bool) -> Void)? = nil) {
        let animation = CAAnimation.springBounceAnimation(keyPath, initialVelocity: initialVelocity, damping: damping)

        animation.fromValue = from
        animation.toValue = to
        animation.isRemovedOnCompletion = removeOnCompletion
        animation.fillMode = .forwards
        if let completion = completion {
            animation.delegate = AnimationDelegate(animation: animation, completion: completion)
        }

        let k = Float(CAAnimation.animationDurationFactor)
        var speed: Float = 1.0
        if k != 0, k != 1 {
            speed = Float(1.0) / k
        }

        if !delay.isZero {
            animation.beginTime = convertTime(CACurrentMediaTime(), from: nil) + delay * CAAnimation.animationDurationFactor
            animation.fillMode = .both
        }

        animation.speed = speed * Float(animation.duration / duration)
        animation.isAdditive = additive

        animation.adjustFrameRate()

        add(animation, forKey: keyPath)
    }

    func animateAlpha(from: CGFloat? = nil, to: CGFloat, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, completion: ((Bool) -> Void)? = nil) {
        animate(from: from != nil ? NSNumber(value: Float(from!)) : nil, to: NSNumber(value: Float(to)), keyPath: "opacity", timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, completion: completion)
    }

    func animateScale(from: CGFloat? = nil, to: CGFloat, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, additive: Bool = false, completion: ((Bool) -> Void)? = nil) {
        animate(from: from != nil ? NSNumber(value: Float(from!)) : nil, to: NSNumber(value: Float(to)), keyPath: "transform.scale", timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, additive: additive, completion: completion)
    }

    func animateScaleX(from: CGFloat? = nil, to: CGFloat, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, completion: ((Bool) -> Void)? = nil) {
        animate(from: from != nil ? NSNumber(value: Float(from!)) : nil, to: NSNumber(value: Float(to)), keyPath: "transform.scale.x", timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, completion: completion)
    }

    func animateScaleY(from: CGFloat? = nil, to: CGFloat, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, completion: ((Bool) -> Void)? = nil) {
        animate(from: from != nil ? NSNumber(value: Float(from!)) : nil, to: NSNumber(value: Float(to)), keyPath: "transform.scale.y", timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, completion: completion)
    }

    func animateTranslationX(from: CGFloat? = nil, to: CGFloat, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, completion: ((Bool) -> Void)? = nil) {
        animate(from: from != nil ? NSNumber(value: Float(from!)) : nil, to: NSNumber(value: Float(to)), keyPath: "transform.translation.x", timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, completion: completion)
    }

    func animateTranslationY(from: CGFloat? = nil, to: CGFloat, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, completion: ((Bool) -> Void)? = nil) {
        animate(from: from != nil ? NSNumber(value: Float(from!)) : nil, to: NSNumber(value: Float(to)), keyPath: "transform.translation.y", timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, completion: completion)
    }

    func animateRotation(from: CGFloat? = nil, to: CGFloat, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, completion: ((Bool) -> Void)? = nil) {
        animate(from: from != nil ? NSNumber(value: Float(from!)) : nil, to: NSNumber(value: Float(to)), keyPath: "transform.rotation.z", timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, completion: completion)
    }

    func animatePosition(from: CGPoint? = nil, to: CGPoint, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, additive: Bool = false, force: Bool = false, completion: ((Bool) -> Void)? = nil) {
        if from == to, !force {
            if let completion = completion {
                completion(true)
            }
            return
        }
        animate(from: from != nil ? NSValue(cgPoint: from!) : nil, to: NSValue(cgPoint: to), keyPath: "position", timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, additive: additive, completion: completion)
    }

    func animateBounds(from: CGRect? = nil, to: CGRect, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction, removeOnCompletion: Bool = true, additive: Bool = false, force: Bool = false, completion: ((Bool) -> Void)? = nil) {
        if from == to, !force {
            if let completion = completion {
                completion(true)
            }
            return
        }
        animate(from: from != nil ? NSValue(cgRect: from!) : nil, to: NSValue(cgRect: to), keyPath: "bounds", timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, additive: additive, completion: completion)
    }

    func animateWidth(from: CGFloat? = nil, to: CGFloat, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, additive: Bool = false, force: Bool = false, completion: ((Bool) -> Void)? = nil) {
        if from == to, !force {
            if let completion = completion {
                completion(true)
            }
            return
        }
        animate(from: from != nil ? NSNumber(value: Float(from!)) : nil, to: to as NSNumber, keyPath: "bounds.size.width", timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, additive: additive, completion: completion)
    }

    func animateHeight(from: CGFloat? = nil, to: CGFloat, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, additive: Bool = false, force: Bool = false, completion: ((Bool) -> Void)? = nil) {
        if from == to, !force {
            if let completion = completion {
                completion(true)
            }
            return
        }
        animate(from: from != nil ? NSNumber(value: Float(from!)) : nil, to: to as NSNumber, keyPath: "bounds.size.height", timingFunction: timingFunction, duration: duration, delay: delay, removeOnCompletion: removeOnCompletion, additive: additive, completion: completion)
    }

    func animateBoundsOriginXAdditive(from: CGFloat? = nil, to: CGFloat, duration: Double, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, completion: ((Bool) -> Void)? = nil) {
        animate(from: from != nil ? NSNumber(value: Float(from!)) : nil, to: to as NSNumber, keyPath: "bounds.origin.x", timingFunction: timingFunction, duration: duration, removeOnCompletion: removeOnCompletion, additive: true, completion: completion)
    }

    func animateBoundsOriginYAdditive(from: CGFloat? = nil, to: CGFloat, duration: Double, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, completion: ((Bool) -> Void)? = nil) {
        animate(from: from != nil ? NSNumber(value: Float(from!)) : nil, to: to as NSNumber, keyPath: "bounds.origin.y", timingFunction: timingFunction, duration: duration, removeOnCompletion: removeOnCompletion, additive: true, completion: completion)
    }

    func animatePositionKeyframes(values: [CGPoint], duration: Double, removeOnCompletion: Bool = true, completion: ((Bool) -> Void)? = nil) {
        animateKeyframes(values: values.map { NSValue(cgPoint: $0) }, duration: duration, keyPath: "position", removeOnCompletion: removeOnCompletion, completion: completion)
    }

    func animateFrame(from: CGRect? = nil, to: CGRect, duration: Double, delay: Double = 0.0, timingFunction: AnimationTimingFunction = .easeInEaseOut, removeOnCompletion: Bool = true, additive: Bool = false, force: Bool = false, completion: ((Bool) -> Void)? = nil) {
        if from == to, !force {
            if let completion = completion {
                completion(true)
            }
            return
        }
        var interrupted = false
        var completedPosition = false
        var completedBounds = false
        let partialCompletion: () -> Void = {
            if interrupted || (completedPosition && completedBounds) {
                if let completion = completion {
                    completion(!interrupted)
                }
            }
        }

        let from = from ?? frame
        var fromPosition = CGPoint(x: from.midX, y: from.midY)
        var toPosition = CGPoint(x: to.midX, y: to.midY)

        var fromBounds = CGRect(origin: bounds.origin, size: from.size)
        var toBounds = CGRect(origin: bounds.origin, size: to.size)

        if additive {
            fromPosition.x = -(toPosition.x - fromPosition.x)
            fromPosition.y = -(toPosition.y - fromPosition.y)
            toPosition = CGPoint()

            fromBounds.size.width = -(toBounds.width - fromBounds.width)
            fromBounds.size.height = -(toBounds.height - fromBounds.height)
            toBounds = CGRect()
        }

        animatePosition(from: fromPosition, to: toPosition, duration: duration, delay: delay, timingFunction: timingFunction, removeOnCompletion: removeOnCompletion, additive: additive, force: force, completion: { value in
            if !value {
                interrupted = true
            }
            completedPosition = true
            partialCompletion()
        })
        animateBounds(from: fromBounds, to: toBounds, duration: duration, delay: delay, timingFunction: timingFunction, removeOnCompletion: removeOnCompletion, additive: additive, force: force, completion: { value in
            if !value {
                interrupted = true
            }
            completedBounds = true
            partialCompletion()
        })
    }

    func animateShake(amplitude: CGFloat = 3.0, duration: TimeInterval = 0.3, count: Int = 4, decay: Bool = true, completion: ((Bool) -> Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        var values = [NSNumber]()
        values.append(NSNumber(value: 0.0))
        for i in 0 ..< count {
            let sign = i % 2 == 0 ? 1.0 : -1.0
            let multiplier = decay ? 1.0 / (CGFloat(i) + 1.0) : 1.0
            values.append(NSNumber(value: amplitude * sign * multiplier))
        }
        var keyTimes = [NSNumber]()
        for i in 0 ..< values.count {
            if i == 0 {
                keyTimes.append(NSNumber(value: 0))
            } else if i == values.count - 1 {
                keyTimes.append(NSNumber(value: 1.0))
            } else {
                keyTimes.append(NSNumber(value: CGFloat(i) / (CGFloat(values.count - 1) * 1.0)))
            }
        }

        let k = Float(CAAnimation.animationDurationFactor)
        var speed: Float = 1.0
        if k != 0, k != 1 {
            speed = Float(1.0) / k
        }

        animation.values = values
        animation.keyTimes = keyTimes
        animation.speed = speed
        animation.duration = duration
        animation.isAdditive = true
        if let completion = completion {
            animation.delegate = AnimationDelegate(animation: animation, completion: completion)
        }

        animation.adjustFrameRate()

        add(animation, forKey: "shake")
    }

    func cancelAnimationsRecursive(key: String) {
        removeAnimation(forKey: key)
        if let sublayers = sublayers {
            for layer in sublayers {
                layer.cancelAnimationsRecursive(key: key)
            }
        }
    }
}
