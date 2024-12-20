//
//  RangeSlider.swift
//  CombineCocoa
//
//  Created by xueqooy on 2024/1/21.
//

import UIKit
import XKit

public class RangeSlider: UIControl {
    static let thumbSize = CGSize.square(20)
    static let trackThickness = 7.0
    static let thumbTouchSlop = 5.0
    static let intrinsicHeight = 46.0

    /// If you set the minimum value to a value larger than the maximum, the slider updates the maximum value to equal the minimum.
    public var minimumValue: Double = 0 {
        didSet {
            guard !isAdjustingValues, oldValue != minimumValue else { return }

            adjustValuesWithoutUpdate {
                maximumValue = max(maximumValue, minimumValue)
                lowerValue = lowerValue.bound(toMin: minimumValue, max: maximumValue)
                upperValue = upperValue.bound(toMin: minimumValue, max: maximumValue)
            }

            updateAnimationEnabler()
            updateLayers()
        }
    }

    /// If you set the maximum value to a value smaller than the minimum, the slider updates the minimum value to equal the maximum.
    public var maximumValue: Double = 100 {
        didSet {
            guard !isAdjustingValues, oldValue != maximumValue else { return }

            adjustValuesWithoutUpdate {
                minimumValue = min(maximumValue, minimumValue)
                lowerValue = lowerValue.bound(toMin: minimumValue, max: maximumValue)
                upperValue = upperValue.bound(toMin: minimumValue, max: maximumValue)
            }

            updateAnimationEnabler()
            updateLayers()
        }
    }

    @EquatableState
    public var lowerValue: Double = 0 {
        didSet {
            defer {
                lowerTextLabel.text = textProvider?(lowerValue) ?? String(format: "%.2f", lowerValue)
            }

            guard !isAdjustingValues, oldValue != lowerValue else { return }

            lowerValue = lowerValue
                .bound(toMin: minimumValue, max: upperValue - minimumSpan)
                .bound(toMin: minimumValue, max: maximumValue)

            adjustValuesWithoutUpdate {
                // make sure upper value >= lower value
                upperValue = upperValue.bound(toMin: lowerValue, max: maximumValue)
            }

            updateLayers()
        }
    }

    @EquatableState
    public var upperValue: Double = 100 {
        didSet {
            defer {
                upperTextLabel.text = textProvider?(upperValue) ?? String(format: "%.2f", upperValue)
            }

            guard !isAdjustingValues, oldValue != upperValue else { return }

            upperValue = upperValue
                .bound(toMin: lowerValue + minimumSpan, max: maximumValue)
                .bound(toMin: minimumValue, max: maximumValue)

            adjustValuesWithoutUpdate {
                // make sure lower value <= upper value
                lowerValue = lowerValue.bound(toMin: minimumValue, max: upperValue)
            }

            updateLayers()
        }
    }

    // Default is 0 (Disabled)
    public var stepValue: Double = 0 {
        didSet {
            guard oldValue != stepValue else { return }

            updateAnimationEnabler()
        }
    }

    // This is the minimum distance between between the upper and lower values
    public var minimumSpan: Double = 0

    override public var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Self.intrinsicHeight)
    }

    public typealias TextProvider = (Double) -> String
    public var textProvider: TextProvider? {
        didSet {
            lowerTextLabel.text = textProvider?(lowerValue) ?? String(format: "%.2f", lowerValue)
            upperTextLabel.text = textProvider?(upperValue) ?? String(format: "%.2f", upperValue)
        }
    }

    private let trackLayer = RangeSliderTrackLayer()
    private let lowerThumbLayer = RangeSliderThumbLayer()
    private let upperThumbLayer = RangeSliderThumbLayer()

    private let layerLayoutGuide = UILayoutGuide()

    private let lowerTextLabel = UILabel(textColor: Colors.teal, font: Fonts.body2)
    private let upperTextLabel = UILabel(textColor: Colors.teal, font: Fonts.body2)

    private var isAdjustingValues: Bool = false

    private lazy var hapticFeedback = HapticFeedback()

    public init(minimumValue: Double = 0, maximumValue: Double = 100, lowerValue: Double = 0, upperValue: Double = 100, stepValue: Double = 0, minimumSpan: Double = 0, textProvider: TextProvider? = nil) {
        super.init(frame: .zero)

        // maximumValue >= minimumValue
        let maximumValue = max(maximumValue, minimumValue)
        // minimumValue <= lowerValue <= maximumValue
        let lowerValue = lowerValue.bound(toMin: minimumValue, max: maximumValue)
        // lowerValue <= upperValue <= maximumValue
        let upperValue = upperValue.bound(toMin: lowerValue, max: maximumValue)

        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.lowerValue = lowerValue
        self.upperValue = upperValue
        self.stepValue = stepValue
        self.minimumSpan = minimumSpan
        self.textProvider = textProvider

        initialize()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        updateLayers()
    }

    private func initialize() {
        updateAnimationEnabler()

        addLayoutGuide(layerLayoutGuide)
        layerLayoutGuide.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(Self.thumbSize.height)
        }

        trackLayer.slider = self

        [trackLayer, lowerThumbLayer, upperThumbLayer]
            .forEach { layer.addSublayer($0) }

        [lowerTextLabel, upperTextLabel]
            .forEach { addSubview($0) }

        lowerTextLabel.snp.makeConstraints { make in
            make.left.equalTo(layerLayoutGuide)
            make.top.equalTo(layerLayoutGuide.snp.bottom).offset(CGFloat.XUI.spacing2)
        }

        upperTextLabel.snp.makeConstraints { make in
            make.right.equalTo(layerLayoutGuide)
            make.top.equalTo(layerLayoutGuide.snp.bottom).offset(CGFloat.XUI.spacing2)
        }
    }

    private func updateLayers() {
        let trackRect = layerLayoutGuide.layoutFrame
        let lowerThumbCenter = position(for: lowerValue)
        let upperThumbCenter = position(for: upperValue)

        trackLayer.frame = trackRect
        trackLayer.setNeedsDisplay()
        trackLayer.setNeedsLayout()

        lowerThumbLayer.frame = .init(origin: .init(x: lowerThumbCenter - Self.thumbSize.width / 2, y: 0), size: Self.thumbSize)
        lowerThumbLayer.setNeedsDisplay()

        upperThumbLayer.frame = .init(origin: .init(x: upperThumbCenter - Self.thumbSize.width / 2, y: 0), size: Self.thumbSize)
        upperThumbLayer.setNeedsDisplay()
    }

    private func updateAnimationEnabler() {
        let length = maximumValue - minimumValue
        var isAnimationEnabled = false

        if length > 0 {
            // When the step proportion exceeds 1%, enable animation
            isAnimationEnabled = stepValue / length > 0.01
        }

        for item in [trackLayer, lowerThumbLayer, upperThumbLayer] {
            item.isAnimationEnabled = isAnimationEnabled
        }
    }

    private func adjustValuesWithoutUpdate(_ block: () -> Void) {
        isAdjustingValues = true

        block()

        isAdjustingValues = false
    }

    // MARK: Tracking

    private var beginLocation: CGPoint = .zero
    private var lowerTouchOffset: Double = 0
    private var upperTouchOffset: Double = 0

    override public func beginTracking(_ touch: UITouch, with _: UIEvent?) -> Bool {
        beginLocation = touch.location(in: self)

        // Hit test the thumb layers
        if lowerThumbLayer.frame.inset(by: .init(uniformValue: -5)).contains(beginLocation) {
            lowerThumbLayer.isHighlighted = true
            lowerTouchOffset = beginLocation.x - lowerThumbLayer.position.x
        }

        if upperThumbLayer.frame.inset(by: .init(uniformValue: -5)).contains(beginLocation) {
            upperThumbLayer.isHighlighted = true
            upperTouchOffset = beginLocation.x - upperThumbLayer.position.x
        }

        let shouldContinueTracking = lowerThumbLayer.isHighlighted || upperThumbLayer.isHighlighted
        if shouldContinueTracking && stepValue > 0 {
            hapticFeedback.prepare()
        }

        return shouldContinueTracking
    }

    override public func continueTracking(_ touch: UITouch, with _: UIEvent?) -> Bool {
        let location = touch.location(in: self)

        // If both thumbs are highlighted, determine which thumb can be dragged
        if lowerThumbLayer.isHighlighted && upperThumbLayer.isHighlighted {
            if lowerValue == upperValue {
                // If lower value equal to upper value, determine based on direction
                if location.x > beginLocation.x {
                    lowerThumbLayer.isHighlighted = false
                } else {
                    upperThumbLayer.isHighlighted = false
                }
            } else {
                // If lower value don‘t equal to upper value, determine based on the distance between touch center and thumb center
                let distanceToLowerThumb = location.distance(to: lowerThumbLayer.position)
                let distanceToUpperThumb = location.distance(to: upperThumbLayer.position)

                if distanceToLowerThumb > distanceToUpperThumb {
                    lowerThumbLayer.isHighlighted = false
                } else {
                    upperThumbLayer.isHighlighted = false
                }
            }
        }

        // Update the values
        if lowerThumbLayer.isHighlighted {
            lowerThumbLayer.zPosition = 1
            upperThumbLayer.zPosition = 0

            let value = value(for: location, offset: lowerTouchOffset)

            let previousLowerValue = lowerValue

            lowerValue = value
                .step(by: stepValue)
                .bound(toMin: minimumValue, max: upperValue)

            if previousLowerValue != lowerValue {
                sendActions(for: .valueChanged)

                if stepValue > 0 {
                    hapticFeedback.trigger()
                }
            }

        } else if upperThumbLayer.isHighlighted {
            lowerThumbLayer.zPosition = 0
            upperThumbLayer.zPosition = 1

            let value = value(for: location, offset: upperTouchOffset)

            let previousUpperValue = upperValue
            upperValue = value
                .step(by: stepValue)
                .bound(toMin: lowerValue, max: maximumValue)

            if previousUpperValue != upperValue {
                sendActions(for: .valueChanged)

                if stepValue > 0 {
                    hapticFeedback.trigger()
                }
            }
        }

        return true
    }

    override public func endTracking(_: UITouch?, with _: UIEvent?) {
        lowerThumbLayer.isHighlighted = false
        upperThumbLayer.isHighlighted = false
    }
}

// MARK: - Utils

extension RangeSlider {
    func position(for value: Double) -> Double {
        let trackWidth = layerLayoutGuide.layoutFrame.width
        return Double(trackWidth - Self.thumbSize.width) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(Self.thumbSize.width / 2)
    }

    func value(for location: CGPoint, offset: CGFloat) -> Double {
        let trackWidth = layerLayoutGuide.layoutFrame.width
        let position = location.x - offset - Self.thumbSize.width / 2
        let value = (maximumValue - minimumValue) * position / Double(trackWidth - Self.thumbSize.width)

        return value
    }
}

private extension Double {
    func step(by stepValue: Double) -> Double {
        var value = self
        if stepValue > 0 {
            value = (value / stepValue).rounded(.up) * stepValue
        }
        return value
    }

    func bound(toMin minValue: Double, max maxValue: Double) -> Double {
        min(max(self, minValue), maxValue)
    }
}
