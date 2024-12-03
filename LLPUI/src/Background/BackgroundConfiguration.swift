//
//  BackgroundConfiguration.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit
import LLPUtils

public struct BackgroundConfiguration: Equatable, Then {
    
    public struct Stroke: Equatable {
        /// Configures the color of the stroke. A nil value uses the view's tint color.
        public var color: UIColor?
        /// The width of the stroke. Default is 0.
        public var width: CGFloat = 0
        /// Outset (or inset, if negative) for the stroke. Default is 0.
        /// The corner radius of the stroke is adjusted for any outset to remain concentric with the background.
        public var outset: CGFloat = 0
        
        public init(color: UIColor? = nil, width: CGFloat = 0, outset: CGFloat = 0) {
            self.color = color
            self.width = width
            self.outset = outset
        }
    }
    
    public struct Shadow: Equatable {
        /// offset in user space of the shadow
        public var offset: CGSize = .zero
        /// blur radius of the shadow in default user space units
        public var blurRadius: CGFloat = 3
        /// color used for the shadow
        public var color: UIColor?
        
        public init(offset: CGSize = .zero, blurRadius: CGFloat = 3, color: UIColor? = nil) {
            self.offset = offset
            self.blurRadius = blurRadius
            self.color = color
        }
    }
    
    public struct Gradient: Equatable {
        public enum Style {
            case axial, radial, conic
        }
        
        /// The colors of the gradient
        public var colors: [UIColor]
        /// The locations of the gradient stops. If nil, the stops are spread uniformly across the range.
        public var locations: [CGFloat]?
        /// The start point of the gradient when drawn in the layer’s coordinate space
        public var startPoint = CGPoint(x: 0.5, y: 0)
        /// The end point of the gradient when drawn in the layer’s coordinate space
        public var endPoint = CGPoint(x: 0.5, y: 1)
        /// The style of the gradient
        public var style: Style = .axial
        
        public init(colors: [UIColor],
                    locations: [CGFloat]? = nil,
                    startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
                    endPoint: CGPoint = CGPoint(x: 0.5, y: 1),
                    style: Style = .axial) {
            self.colors = colors
            self.locations = locations
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.style = style
        }
    }
    
    /// Configures the color of the background
    public var fillColor: UIColor?
    /// The visual effect to apply to the background. Default is nil.
    public var visualEffect: UIVisualEffect?
    /// The image to use. Default is nil.
    public var image: UIImage?
    /// The content mode to use when rendering the image. Default is UIViewContentModeScaleToFill.
    public var imageContentMode: UIView.ContentMode = .scaleToFill
    /// The corner style for the background and stroke. This is also applied to the custom view. Default is .fixed(0).
    public var cornerStyle: CornerStyle?
    /// Defines which of the four corners receives the masking when using cornerStyle
    public var maskedCorners: UIRectCorner = .allCorners
    
    public var stroke: Stroke = Stroke()
        
    public var shadow: Shadow = Shadow()
    
    public var gradient: Gradient?
    
    public init(fillColor: UIColor? = nil,
                visualEffect: UIVisualEffect? = nil,
                image: UIImage? = nil,
                imageContentMode: UIView.ContentMode = .scaleToFill,
                cornerStyle: CornerStyle? = nil,
                maskedCorners: UIRectCorner = .allCorners,
                stroke: Stroke = Stroke(),
                shadow: Shadow = Shadow(),
                gradient: Gradient? = nil) {
        self.fillColor = fillColor
        self.stroke = stroke
        self.cornerStyle = cornerStyle
        self.maskedCorners = maskedCorners
        self.visualEffect = visualEffect
        self.image = image
        self.imageContentMode = imageContentMode
        self.shadow = shadow
        self.gradient = gradient
    }
    
    public init(fillColor: UIColor? = nil,
                visualEffect: UIVisualEffect? = nil,
                image: UIImage? = nil,
                imageContentMode: UIView.ContentMode = .scaleToFill,
                cornerStyle: CornerStyle? = nil,
                maskedCorners: UIRectCorner = .allCorners,
                strokeColor: UIColor? = nil,
                strokeWidth: CGFloat = 0,
                strokeOutset: CGFloat = 0,
                shadowOffset: CGSize = .zero,
                shadowBlurRadius: CGFloat = 3,
                shadowColor: UIColor? = nil,
                gradient: Gradient? = nil) {
        self.fillColor = fillColor
        self.visualEffect = visualEffect
        self.image = image
        self.imageContentMode = imageContentMode
        self.cornerStyle = cornerStyle
        self.maskedCorners = maskedCorners
        self.stroke = .init(color: strokeColor, width: strokeWidth, outset: strokeOutset)
        self.shadow = .init(offset: shadowOffset, blurRadius: shadowBlurRadius, color: shadowColor)
        self.gradient = gradient
    }
    
    public init() {}
}
