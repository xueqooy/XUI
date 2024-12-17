//
//  PlaybackProgressSlider.swift
//  XUI
//
//  Created by xueqooy on 2024/5/20.
//

import UIKit
import XKit

public class PlaybackProgressSlider: UISlider {
        
    public enum Event {
        case seekingUpdated(Float)
        case seekingEnded
    }
    
    public override var maximumValue: Float {
        willSet {
            Asserts.failure("maximumValue can only set to 1", condition: maximumValue == 1)
        }
    }
    
    public override var minimumValue: Float {
        willSet {
            Asserts.failure("minimumValue can only set to 0", condition: minimumValue == 0)
        }
    }
    
    public var eventHandler: ((Event) -> Void)?
    
    public var bufferedPosition: Float = 0 {
        didSet {
            guard oldValue != bufferedPosition else { return }
            
            updateBufferRect()
        }
    }
        
    private var isSeeking: Bool = false {
        didSet {
            guard oldValue != isSeeking else { return }
            
            setThumbImage(isSeeking ? UIImage(): Icons.progressThumbSmall, for: .normal)

            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private let bufferLayer: CALayer
        
    public override init(frame: CGRect) {
        bufferLayer = CALayer()
        bufferLayer.backgroundColor = Colors.line1.withAlphaComponent(0.4).cgColor
        
        super.init(frame: frame)
        
        maximumTrackTintColor = Colors.line1.withAlphaComponent(0.3)
        minimumTrackTintColor = Colors.mediumTeal
        setThumbImage(Icons.progressThumbSmall, for: .normal)

        layer.insertSublayer(bufferLayer, at: 0)
                
        addTarget(self, action: #selector(Self.startSeeking), for: .touchDown)
        addTarget(self, action: #selector(Self.endSeeking), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        addTarget(self, action: #selector(Self.valueChanged), for: .valueChanged)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(Self.panGestureAction))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        updateBufferRect()
    }
    
    public override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var trackRect = super.trackRect(forBounds: bounds)
        
        if isSeeking {
            trackRect.size.height *= 2
            trackRect.origin.y = (bounds.height - trackRect.height) / 2
        }
        
        return trackRect
    }
    
    private func updateBufferRect() {
        var bufferRect = trackRect(forBounds: bounds)
        bufferRect.size.width = bufferRect.width * CGFloat(bufferedPosition)
        
        bufferLayer.frame = bufferRect
    }
    
    @objc private func startSeeking() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.isSeeking = true
        }
        self.eventHandler?(.seekingUpdated(value))
    }
    
    @objc private func valueChanged() {
        self.eventHandler?(.seekingUpdated(value))
    }
    
    @objc private func endSeeking() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
            self.isSeeking = false
        }
        self.eventHandler?(.seekingEnded)
    }
        
    private var referenceValue: Float = 0
    private var followLocaton = false
    
    @objc private func panGestureAction(_ sender: UIPanGestureRecognizer) {
        guard bounds.width > 0 else { return }
        
        switch sender.state {
        case .began:
            followLocaton = false
            referenceValue = value
            startSeeking()
            
        case .changed:
            let location = sender.location(in: self)
            if value == 0 && location.x < 0 || value == 1 && location.x > bounds.width {
                followLocaton = true
                return
            }
            
            var pendingValue: Float
            
            if followLocaton {
                pendingValue = Float(location.x / bounds.width)
                
            } else {
                // Update value based on translation
                let translation = sender.translation(in: self)
                
                let valueOffset = translation.x / bounds.width
                pendingValue = referenceValue + Float(valueOffset)
                
                if pendingValue < 0 {
                    referenceValue = 0
                    
                    sender.setTranslation(.zero, in: self)
                } else if pendingValue > 1 {
                    referenceValue = 1
                    
                    sender.setTranslation(.zero, in: self)
                }
            }
            
            pendingValue = max(0, min(1, pendingValue))
            let changed = pendingValue != value
            value = pendingValue
            if changed {
                valueChanged()
            }
    
        default:
            endSeeking()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        .init(width: UIView.noIntrinsicMetric, height: 30)
    }
}
