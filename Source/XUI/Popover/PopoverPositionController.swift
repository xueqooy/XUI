//
//  PopoverPositionController.swift
//  XUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit

class PopoverPositionController {
    var popoverRect: CGRect {
        CGRect(origin: popoverOrigin, size: popoverSize)
    }

    var arrowOffset: CGFloat {
        let arrowMargin: CGFloat
        switch configuration.background.cornerStyle {
        case let .fixed(value):
            arrowMargin = value
        case .capsule:
            // Based on actual corner radius.
            arrowMargin = arrowPosition.isVertical ? popoverSize.height / 2 : 0
        case .none:
            arrowMargin = 0
        }
        let arrowWidth = configuration.arrowSize.width
        let minOffset = arrowMargin
        var idealOffset: CGFloat
        var maxOffset: CGFloat

        if arrowPosition.isVertical {
            idealOffset = sourcePointInSuperview.x - popoverRect.minX - arrowWidth / 2
            maxOffset = popoverRect.width - arrowMargin - arrowWidth
        } else {
            idealOffset = sourcePointInSuperview.y - popoverRect.minY - arrowWidth / 2
            maxOffset = popoverRect.height - arrowMargin - arrowWidth
        }
        return max(minOffset, min(idealOffset, maxOffset))
    }

    var popoverAnchorPoint: CGPoint {
        if arrowPosition.isVertical {
            return CGPoint(x: (arrowOffset + configuration.arrowSize.width / 2) / popoverSize.width, y: arrowPosition == .top ? 0 : 1)
        } else {
            return CGPoint(x: arrowPosition == .left ? 0 : 1, y: (arrowOffset + configuration.arrowSize.height / 2) / popoverSize.height)
        }
    }

    private(set) var direction: Direction = .down

    private var popoverSize: CGSize = .zero
    private var popoverContainerHeight: CGFloat {
        if arrowPosition.isVertical {
            return popoverSize.height - configuration.arrowSize.height
        } else {
            return popoverSize.height
        }
    }

    private lazy var popoverOrigin: CGPoint = {
        var result = idealPopoverOrigin
        if arrowPosition.isVertical {
            result.x = max(boundingRect.minX, min(result.x, boundingRect.maxX - popoverSize.width))
        } else {
            result.y = max(boundingRect.minY, min(result.y, boundingRect.maxY - popoverSize.height))
        }
        result.x += configuration.offset.x
        result.y += configuration.offset.y
        return result
    }()

    private var idealPopoverOrigin: CGPoint {
        switch arrowPosition {
        case .top:
            return CGPoint(x: sourcePointInSuperview.x - popoverSize.width / 2, y: sourcePointInSuperview.y)
        case .bottom:
            return CGPoint(x: sourcePointInSuperview.x - popoverSize.width / 2, y: sourcePointInSuperview.y - popoverSize.height)
        case .left:
            return CGPoint(x: sourcePointInSuperview.x, y: sourcePointInSuperview.y - popoverSize.height / 2)
        case .right:
            return CGPoint(x: sourcePointInSuperview.x - popoverSize.width, y: sourcePointInSuperview.y - popoverSize.height / 2)
        }
    }

    private var sourcePointInAnchorView: CGPoint {
        switch arrowPosition {
        case .top:
            return CGPoint(x: anchorView.frame.width / 2, y: anchorView.frame.height)
        case .bottom:
            return CGPoint(x: anchorView.frame.width / 2, y: 0)
        case .right:
            return CGPoint(x: 0, y: anchorView.frame.height / 2)
        case .left:
            return CGPoint(x: anchorView.frame.width, y: anchorView.frame.height / 2)
        }
    }

    private var sourcePointInSuperview: CGPoint {
        return anchorView.convert(sourcePointInAnchorView, to: superview)
    }

    private let contentView: UIView
    private let preferredContentsize: CGSize
    private let anchorView: UIView
    private let superview: UIView
    private let configuration: Popover.Configuration
    private let boundingRect: CGRect

    init(contentView: UIView, preferredContentSize: CGSize = .zero, superview: UIView, anchorView: UIView, configuration: Popover.Configuration) {
        let keyboardHeightInSuperview = KeyboardManager.visibleRect(in: superview)?.height ?? 0 // .distanceFromMinYToBottom(of: superview)

        let boundingRect = superview.bounds
            .inset(by: keyboardHeightInSuperview > 0 ? .zero : superview.safeAreaInsets)
            .inset(by: configuration.superviewMargins)
            .inset(by: UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeightInSuperview, right: 0))

        self.contentView = contentView
        preferredContentsize = preferredContentSize
        self.anchorView = anchorView
        self.superview = superview
        self.configuration = configuration
        self.boundingRect = boundingRect

        resolveDirectionAndPopoverSize()
    }

    private func resolveDirectionAndPopoverSize() {
        typealias BoundingRectAndPopoverSize = (boundingRect: CGRect, popoverSize: CGSize)
        typealias Results = (direction: Direction, boundingRectAndPopoverSize: BoundingRectAndPopoverSize)

        /**
         1. Determine preferred results
         2. If the preferred results is optimal, determine it as the final results
         3. Otherwise, traverse the alternative results until the optimal one is found, otherwise determine the preferred results as the final results.
         */

        let preferredDirection = configuration.preferredDirection
        let preferredBoundingRectAndPopoverSize = boundingRectAndPopoverSize(for: preferredDirection)
        let preferredResults: Results = (preferredDirection, preferredBoundingRectAndPopoverSize)
        var finalResults: Results = preferredResults
        let alternativeDirections: [Direction] = preferredDirection.isVertical ?
            [preferredDirection.opposite, .fromLeading, .fromTrailing] :
            [preferredDirection.opposite, .down, .up]

        func isValid(_ boundingRectAndPopoverSize: BoundingRectAndPopoverSize) -> Bool {
            boundingRectAndPopoverSize.boundingRect.size.width > 0 && boundingRectAndPopoverSize.boundingRect.size.height > 0 && boundingRectAndPopoverSize.popoverSize.width > 0 && boundingRectAndPopoverSize.popoverSize.height > 0
        }

        let isPreferrenceValid = isValid(preferredBoundingRectAndPopoverSize)

        func isOptimal(_ result: Results) -> Bool {
            guard isValid(result.boundingRectAndPopoverSize) else {
                return false
            }

            guard isPreferrenceValid else {
                return true
            }

            if result.direction.isVertical {
                if result.boundingRectAndPopoverSize.boundingRect.size.height >= result.boundingRectAndPopoverSize.popoverSize.height {
                    return true
                }
            } else {
                if result.boundingRectAndPopoverSize.boundingRect.size.width >= result.boundingRectAndPopoverSize.popoverSize.width {
                    return true
                }
            }

            return false
        }

        if !isOptimal(finalResults) {
            for direction in alternativeDirections {
                let boundingRectAndPopoverSize = boundingRectAndPopoverSize(for: direction)
                let results = (direction, boundingRectAndPopoverSize)

                if isOptimal(results) {
                    finalResults = results
                    break
                }
            }
        }

        direction = finalResults.direction
        if configuration.limitsToBounds {
            popoverSize = finalResults.boundingRectAndPopoverSize.popoverSize.limit(to: finalResults.boundingRectAndPopoverSize.boundingRect.size)
        } else {
            popoverSize = finalResults.boundingRectAndPopoverSize.popoverSize
        }
    }

    private func boundingRectAndPopoverSize(for direction: Direction) -> (CGRect, CGSize) {
        let boundingRect = boundingRect.inset(by: anchorViewInset(for: direction))
        let popoverSize = sizeThatFits(boundingRect.size, direction: direction)

        return (boundingRect, popoverSize)
    }

    private func anchorViewInset(for direction: Direction) -> UIEdgeInsets {
        var inset = UIEdgeInsets.zero
        let anchorViewFrame = anchorView.convert(anchorView.bounds, to: superview)
        switch arrowPosition(for: direction) {
        case .top:
            inset.top = max(anchorViewFrame.maxY - boundingRect.minY, 0)
        case .bottom:
            inset.bottom = max(boundingRect.maxY - anchorViewFrame.minY, 0)
        case .left:
            inset.left = max(anchorViewFrame.maxX - boundingRect.minX, 0)
        case .right:
            inset.right = max(boundingRect.maxX - anchorViewFrame.minX, 0)
        }
        return inset
    }

    private func sizeThatFits(_ size: CGSize, direction: Direction) -> CGSize {
        let configuration = self.configuration
        let arrowSize = configuration.arrowSize
        let paddingVertical = configuration.contentInsets.top + configuration.contentInsets.bottom
        let paddingHorizontal = configuration.contentInsets.left + configuration.contentInsets.right

        // Content size priority order:
        // preferredContentSize > contentView.systemLayoutSizeFitting

        var finalContentSize: CGSize = .zero
        let updateContentSize = { (getWidth: @autoclosure () -> CGFloat, getHeight: @autoclosure () -> CGFloat) in
            if finalContentSize.width <= 0 {
                if let maximumContentWidth = configuration.maximumContentWidth {
                    finalContentSize.width = min(maximumContentWidth, getWidth())
                } else {
                    finalContentSize.width = getWidth()
                }
            }
            if finalContentSize.height <= 0 {
                if let maximumContentHeight = configuration.maximumContentHeight {
                    finalContentSize.height = min(maximumContentHeight, getHeight())
                } else {
                    finalContentSize.height = getHeight()
                }
            }
        }

        updateContentSize(preferredContentsize.width, preferredContentsize.height)

        if finalContentSize.width <= 0 || finalContentSize.height <= 0 {
            var boundingSize = size
            if direction.isVertical {
                boundingSize.height -= arrowSize.height
            } else {
                boundingSize.width -= arrowSize.width
            }
            boundingSize.width -= paddingHorizontal
            boundingSize.height -= paddingVertical

            if let maximumContentWidth = configuration.maximumContentWidth {
                boundingSize.width = min(maximumContentWidth, boundingSize.width)
            }
            if let maximumContentHeight = configuration.maximumContentHeight {
                boundingSize.height = min(maximumContentHeight, boundingSize.height)
            }

            var targetSize: CGSize = boundingSize
            let contentFittingSize: CGSize
            if finalContentSize.width > 0 {
                targetSize.width = finalContentSize.width
                contentFittingSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            } else if finalContentSize.height > 0 {
                targetSize.height = finalContentSize.height
                contentFittingSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
            } else {
                contentFittingSize = contentView.systemLayoutSizeFitting(boundingSize)
            }
            updateContentSize(contentFittingSize.width, contentFittingSize.height)
        }

        var width = finalContentSize.width + paddingHorizontal
        var height = finalContentSize.height + paddingVertical
        if direction.isVertical {
            height += arrowSize.height
        } else {
            width += arrowSize.height
        }
        return CGSize(width: width, height: height)
    }
}

extension PopoverPositionController {
    enum ArrowPosition {
        case top, left, bottom, right

        var isVertical: Bool {
            switch self {
            case .top, .bottom:
                return true
            case .left, .right:
                return false
            }
        }
    }

    var arrowPosition: ArrowPosition {
        arrowPosition(for: direction)
    }

    func arrowPosition(for direction: Direction) -> ArrowPosition {
        switch direction {
        case .down:
            return .top
        case .up:
            return .bottom
        case .fromLeading:
            return superview.effectiveUserInterfaceLayoutDirection == .leftToRight ? .left : .right
        case .fromTrailing:
            return superview.effectiveUserInterfaceLayoutDirection == .leftToRight ? .right : .left
        }
    }
}
