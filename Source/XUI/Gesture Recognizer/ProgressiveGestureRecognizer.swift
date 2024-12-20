//
//  ProgressiveGestureRecognizer.swift
//  XUI
//
//  Created by xueqooy on 2024/6/7.
//

import Combine
import UIKit
import XKit

public class ProgressivePressGestureRecognizer: UIGestureRecognizer {
    public struct Priority: Hashable, Equatable, RawRepresentable {
        public var rawValue: Int

        public init(_ rawValue: Int) {
            self.rawValue = rawValue
        }

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    @EquatableState
    public private(set) var progress: CGFloat = 0 {
        didSet {
            progressChanged?(progress)
        }
    }

    public var priority: Priority = .default

    private let maxPressDuration: TimeInterval

    private let resetDuration: TimeInterval

    private var animator: DisplayLinkAnimator?

    private let progressChanged: ((CGFloat) -> Void)?

    public init(maxPressDuration: TimeInterval, resetDuration: TimeInterval, progressChanged: ((CGFloat) -> Void)? = nil) {
        self.maxPressDuration = max(0, maxPressDuration)
        self.resetDuration = max(0, resetDuration)
        self.progressChanged = progressChanged

        super.init(target: nil, action: nil)

        cancelsTouchesInView = false
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        guard touches.count == 1 else {
            state = .failed
            return
        }

        animator = nil

        if maxPressDuration > 0 {
            let duration = (1.0 - progress) * maxPressDuration

            animator = DisplayLinkAnimator(duration: duration, from: progress, to: 1, update: { [weak self] value in
                guard let self else { return }

                if self.state == .began || self.state == .changed {
                    self.progress = value
                } else {
                    self.resetProgress()
                }
            })
        } else {
            progress = 1
        }

        state = .began
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        guard touches.first != nil else {
            state = .failed
            return
        }

        state = .changed
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)

        resetProgress()

        state = .ended
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)

        resetProgress()

        state = .cancelled
    }

    override public func shouldRequireFailure(of otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let otherGestureRecognizer = otherGestureRecognizer as? ProgressivePressGestureRecognizer {
            return priority < otherGestureRecognizer.priority
        }

        let otherName = String(describing: otherGestureRecognizer.classForCoder)

        // Fixed the issue on iPad devices where when adding this gesture to Button, there was a conflict with the _UISystemGestureGateGestureRecognizer gesture and the click event could not be recognized
        return !otherName.contains("_UISystemGestureGate" + "GestureRecognizer")
    }

    override public func reset() {
        super.reset()

        resetProgress()
    }

    private func resetProgress() {
        animator = nil

        guard progress != 0 else {
            return
        }

        if resetDuration > 0 {
            let duration = progress * resetDuration

            animator = DisplayLinkAnimator(duration: duration, from: progress, to: 0, update: { [weak self] value in
                guard let self else { return }

                self.progress = value

            }, completion: { [weak self] in
                guard let self else { return }

                progress = 0
            })
        } else {
            progress = 0
        }
    }
}

extension ProgressivePressGestureRecognizer.Priority: Comparable, ExpressibleByIntegerLiteral {
    public static let background = ProgressivePressGestureRecognizer.Priority(rawValue: -100)

    public static let `default` = ProgressivePressGestureRecognizer.Priority(0)

    public static let button = ProgressivePressGestureRecognizer.Priority(100)

    // MARK: - ExpressibleByIntegerLiteral

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: value)
    }

    // MARK: - Comparable

    public static func < (lhs: ProgressivePressGestureRecognizer.Priority, rhs: ProgressivePressGestureRecognizer.Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    // MARK: - Arithmetic Operations

    public static func + (lhs: ProgressivePressGestureRecognizer.Priority, rhs: ProgressivePressGestureRecognizer.Priority) -> ProgressivePressGestureRecognizer.Priority {
        return ProgressivePressGestureRecognizer.Priority(lhs.rawValue + rhs.rawValue)
    }

    public static func - (lhs: ProgressivePressGestureRecognizer.Priority, rhs: ProgressivePressGestureRecognizer.Priority) -> ProgressivePressGestureRecognizer.Priority {
        return ProgressivePressGestureRecognizer.Priority(lhs.rawValue - rhs.rawValue)
    }

    public static func * (lhs: ProgressivePressGestureRecognizer.Priority, rhs: ProgressivePressGestureRecognizer.Priority) -> ProgressivePressGestureRecognizer.Priority {
        return ProgressivePressGestureRecognizer.Priority(lhs.rawValue * rhs.rawValue)
    }

    public static func / (lhs: ProgressivePressGestureRecognizer.Priority, rhs: ProgressivePressGestureRecognizer.Priority) -> ProgressivePressGestureRecognizer.Priority? {
        guard rhs.rawValue != 0 else { return nil }
        return ProgressivePressGestureRecognizer.Priority(lhs.rawValue / rhs.rawValue)
    }
}
