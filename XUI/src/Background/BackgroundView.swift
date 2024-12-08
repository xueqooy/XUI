//
//  BackgroundView.swift
//  XUI
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
    
    private lazy var gradientView: GradientView = {
        let gradientView = GradientView()
        gradientView.isUserInteractionEnabled = false
        gradientView.clipsToBounds = true
        return gradientView
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
    private var didAddGradientView: Bool = false
    private var didAddVisualEffectView: Bool = false
    private var didAddStrokeView: Bool = false
    private var didAddImageView: Bool = false
    
    private var shouldDisplayShadowView: Bool {
        configuration.shadow.color != nil
    }
    
    private var shouldDisplayColorView: Bool {
        if configuration.visualEffect != nil {
            return false
        } else {
            return configuration.fillColor != nil
        }
    }
    
    private var shouldDisplayGradientView: Bool {
        configuration.gradient != nil
    }
        
    private var shouldDisplayVisualEffectView: Bool {
        configuration.visualEffect != nil
    }
    
    private var shouldDisplayStrokeView: Bool {
        configuration.stroke.width > 0
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
            shadowView.layer.shadowColor = configuration.shadow.color?.cgColor
            shadowView.layer.shadowOffset = configuration.shadow.offset
            shadowView.layer.shadowRadius = configuration.shadow.blurRadius
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
        
        if shouldDisplayGradientView {
            gradientView.applyGradient(configuration.gradient!)
            
            if !gradientView.isDescendant(of: innerContentView) {
                innerContentView.addSubview(gradientView)
                didAddGradientView = true
            }
            innerContentView.bringSubviewToFront(gradientView)
        } else if didAddGradientView {
            gradientView.removeFromSuperview()
            didAddGradientView = false
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
            strokeView.layer.borderColor = configuration.stroke.color?.cgColor ?? self.tintColor.cgColor
            strokeView.layer.borderWidth = configuration.stroke.width
            
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
        
        let maskedCorners = configuration.maskedCorners.asCACornerMask()
        
        innerContentView.frame = bounds
        
        if shouldDisplayShadowView {
            shadowView.frame = bounds
            shadowView.layer.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: configuration.maskedCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        }
        
        if shouldDisplayColorView {
            colorView.frame = bounds
            colorView.layer.cornerRadius = cornerRadius
            colorView.layer.maskedCorners = maskedCorners
        }
        
        if shouldDisplayGradientView {
            gradientView.frame = bounds
            gradientView.layer.cornerRadius = cornerRadius
            gradientView.layer.maskedCorners = maskedCorners
        }
        
        if shouldDisplayVisualEffectView {
            visualEffectView.frame = bounds
            visualEffectView.subviews.forEach {
                $0.layer.cornerRadius = cornerRadius
                $0.layer.maskedCorners = maskedCorners
            }
        }
        
        if shouldDisplayImageView {
            imageView.frame = bounds
            imageView.layer.cornerRadius = cornerRadius
            imageView.layer.maskedCorners = maskedCorners
        }
        
        if shouldDisplayStrokeView {
            let outset = configuration.stroke.outset
            strokeView.frame = bounds.inset(by: UIEdgeInsets(top: -outset, left: -outset, bottom: -outset, right: -outset))
            if cornerRadius > 0 {
                strokeView.layer.cornerRadius = cornerRadius + outset
                strokeView.layer.maskedCorners = maskedCorners
            }
        }
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        
        if shouldDisplayStrokeView && configuration.stroke.color == nil {
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
    
    private class GradientView: UIView {
        
        override class var layerClass: AnyClass {
            return CAGradientLayer.self
        }
     
        func applyGradient(_ gradient: BackgroundConfiguration.Gradient) {
            let layer = self.layer as! CAGradientLayer
            layer.colors = gradient.colors.map { $0.cgColor }
            if let locations = gradient.locations {
                layer.locations = locations as [NSNumber]
            } else {
                layer.locations = nil
            }
            layer.startPoint = gradient.startPoint
            layer.endPoint = gradient.endPoint
            layer.type = switch gradient.style {
            case .axial:
                CAGradientLayerType.axial
            case .radial:
                CAGradientLayerType.radial
            case .conic:
                CAGradientLayerType.conic
            }
        }
    }
}
