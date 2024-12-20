//
//  RangeSliderTrackLayer.swift
//  XUI
//
//  Created by xueqooy on 2024/1/23.
//

import UIKit

class RangeSliderTrackLayer: RangeSliderLayer {
    override var isAnimationEnabled: Bool {
        didSet {
            selectedRangeLayer.isAnimationEnabled = isAnimationEnabled
        }
    }

    weak var slider: RangeSlider?

    private let selectedRangeLayer = {
        let layer = RangeSliderLayer()
        layer.backgroundColor = Colors.teal.cgColor
        return layer
    }()

    override init() {
        super.init()

        addSublayer(selectedRangeLayer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers() {
        super.layoutSublayers()

        guard let slider = slider else { return }

        let trackOrginY = (bounds.height - RangeSlider.trackThickness) / 2
        let lowerPosition = slider.position(for: slider.lowerValue)
        let upperPositon = slider.position(for: slider.upperValue)
        let selectedRangeRect = CGRect(x: lowerPosition, y: trackOrginY, width: upperPositon - lowerPosition, height: RangeSlider.trackThickness)

        selectedRangeLayer.frame = selectedRangeRect
    }

    override func draw(in ctx: CGContext) {
        let trackOrginY = (bounds.height - RangeSlider.trackThickness) / 2

        // Clip
        let cornerRadius = RangeSlider.trackThickness / 2
        let trackRect = bounds.insetBy(dx: 0, dy: trackOrginY)
        let trackPath = UIBezierPath(roundedRect: trackRect, cornerRadius: cornerRadius).cgPath

        ctx.addPath(trackPath)

        // Fill the track
        ctx.setFillColor(Colors.line2.cgColor)
        ctx.addPath(trackPath)
        ctx.fillPath()
    }
}
