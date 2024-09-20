//
//  BackgroundView.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/9/20.
//

import UIKit

/// Background view, providing fillet, border, blur, etc
open class BackgroundView: UIView, Configurable {
        
    private let innerContentView = InnerContentView()
    
    private lazy var shadowView: ShadowView = {
        let shadowView = ShadowView()
        shadowView.isUserInteractionEnabled = false
        return shadowView
    }()
    
    private lazy var colorView: ColorView = {
        let colorView = ColorView()
        colorView.isUserInteractionEnabled = false
        colorView.clipsToBounds = true
        return colorView
    }()
    
    private lazy var visualEffectView: VisualEffectView = {
        let visualEffectView = VisualEffectView()
        visualEffectView.isUserInteractionEnabled = false
        visualEffectView.contentView.clipsToBounds = true
        return visualEffectView
    }()
        
    private lazy var imageView: ImageView = {
        let imageView = ImageView()
        imageView.isUserInteractionEnabled = false
        imageView.clipsToBounds = true
        return imageView
    }()
        
    private lazy var strokeView: StrokeView = {
        let strokeView = StrokeView()
        strokeView.isUserInteractionEnabled = false
        strokeView.clipsToBounds = true
        return strokeView
    }()
    
    private var didAddShadowView: Bool = false
    private var didAddColorView: Bool = false
    private var didAddVisualEffectView: Bool = false
    private var didAddStrokeView: Bool = false
    private var didAddImageView: Bool = false
    
    private var shouldDisplayShadowView: Bool {
        configuration.shadowColor != nil
    }
    
    private var shouldDisplayColorView: Bool {
        if configuration.visualEffect != nil {
            return false
        } else {
            return configuration.fillColor != nil
        }
    }
        
    private var shouldDisplayVisualEffectView: Bool {
        configuration.visualEffect != nil
    }
    
    private var shouldDisplayStrokeView: Bool {
        configuration.strokeWidth > 0
    }
    
    private var shouldDisplayImageView: Bool {
        configuration.image != nil
    }
    
    open var configuration: BackgroundConfiguration = .init() {
        didSet {
            if configuration != oldValue {
                update()
                layout()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    public init(configuration: BackgroundConfiguration = BackgroundConfiguration()) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        initialize()
        update()
    }
        
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    private func initialize() {
        self.isUserInteractionEnabled = false
        
        addSubview(innerContentView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    
        layout()
    }
    
    private func update() {
        if shouldDisplayShadowView {
            shadowView.layer.shadowColor = configuration.shadowColor?.cgColor
            shadowView.layer.shadowOffset = configuration.shadowOffset
            shadowView.layer.shadowRadius = configuration.shadowBlurRadius
            shadowView.layer.shadowOpacity = 1
            
            if !shadowView.isDescendant(of: innerContentView) {
                innerContentView.addSubview(shadowView)
                didAddShadowView = true
            }
        } else if didAddShadowView {
            shadowView.removeFromSuperview()
            didAddShadowView = false
        }
        
        if shouldDisplayColorView {
            colorView.backgroundColor = configuration.fillColor
            
            if !colorView.isDescendant(of: innerContentView) {
                innerContentView.addSubview(colorView)
                didAddColorView = true
            }
            innerContentView.bringSubviewToFront(colorView)
        } else if didAddColorView {
            colorView.removeFromSuperview()
            didAddColorView = false
        }
        
        if shouldDisplayVisualEffectView {
            visualEffectView.contentView.backgroundColor = configuration.fillColor
            visualEffectView.effect = configuration.visualEffect
            
            if !visualEffectView.isDescendant(of: innerContentView) {
                innerContentView.addSubview(visualEffectView)
                didAddVisualEffectView = true
            }
            innerContentView.bringSubviewToFront(visualEffectView)
        } else if didAddVisualEffectView {
            visualEffectView.removeFromSuperview()
            didAddVisualEffectView = false
        }
        
        if shouldDisplayImageView {
            imageView.contentMode = configuration.imageContentMode
            imageView.image = configuration.image
            
            if !imageView.isDescendant(of: innerContentView) {
                innerContentView.addSubview(imageView)
                didAddImageView = true
            }
            innerContentView.bringSubviewToFront(imageView)
        } else if didAddImageView {
            imageView.removeFromSuperview()
            didAddImageView = false
        }

        if shouldDisplayStrokeView {
            strokeView.layer.borderColor = configuration.strokeColor?.cgColor ?? self.tintColor.cgColor
            strokeView.layer.borderWidth = configuration.strokeWidth
            
            if !strokeView.isDescendant(of: innerContentView) {
                innerContentView.addSubview(strokeView)
                didAddStrokeView = true
            }
            innerContentView.bringSubviewToFront(strokeView)
        } else if didAddStrokeView {
            strokeView.removeFromSuperview()
            didAddStrokeView = false
        }
    }
    
    private func layout() {
        
        var cornerRadius: CGFloat = 0
        if let cornerStyle = configuration.cornerStyle {
            switch cornerStyle {
            case .fixed(let value):
                cornerRadius = value
            case .capsule:
                cornerRadius = min(bounds.height, bounds.width) / 2.0
            }
        }
        
        let maskedCorner = configuration.stylishCorners.maskedCorners
        
        innerContentView.frame = bounds
        
        if shouldDisplayShadowView {
            shadowView.frame = bounds
            shadowView.layer.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: configuration.stylishCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        }
        
        if shouldDisplayColorView {
            colorView.frame = bounds
            colorView.layer.cornerRadius = cornerRadius
            colorView.layer.maskedCorners = maskedCorner
        }
        
        if shouldDisplayVisualEffectView {
            visualEffectView.frame = bounds
            visualEffectView.subviews.forEach {
                $0.layer.cornerRadius = cornerRadius
                $0.layer.maskedCorners = maskedCorner
            }
        }
        
        if shouldDisplayImageView {
            imageView.frame = bounds
            imageView.layer.cornerRadius = cornerRadius
            imageView.layer.maskedCorners = maskedCorner
        }
        
        if shouldDisplayStrokeView {
            let outset = configuration.strokeOutset
            strokeView.frame = bounds.inset(by: UIEdgeInsets(top: -outset, left: -outset, bottom: -outset, right: -outset))
            if cornerRadius > 0 {
                strokeView.layer.cornerRadius = cornerRadius + outset
                strokeView.layer.maskedCorners = maskedCorner
            }
        }
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        
        if shouldDisplayStrokeView && configuration.strokeColor == nil {
            strokeView.layer.borderColor = self.tintColor.cgColor
        }
    }
    
}

extension BackgroundView {
    private class InnerContentView: UIView {}
    private class ShadowView: UIView {}
    private class VisualEffectView: UIVisualEffectView {}
    private class ColorView: UIView {}
    private class StrokeView: UIView {}
    private class ImageView: UIImageView {}
}
