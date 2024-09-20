//
//  BackgroundConfiguration.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit
import LLPUtils

public struct BackgroundConfiguration: Equatable, Then {
    
    /// Configures the color of the background
    public var fillColor: UIColor?
    /// Configures the color of the stroke. A nil value uses the view's tint color.
    public var strokeColor: UIColor?
    /// The width of the stroke. Default is 0.
    public var strokeWidth: CGFloat = 0
    /// Outset (or inset, if negative) for the stroke. Default is 0.
    /// The corner radius of the stroke is adjusted for any outset to remain concentric with the background.
    public var strokeOutset: CGFloat = 0
    /// The corner style for the background and stroke. This is also applied to the custom view. Default is .fixed(0).
    public var cornerStyle: CornerStyle?
    /// Defines which of the four corners receives the masking when using cornerStyle
    public var stylishCorners: UIRectCorner = .allCorners
    /// The visual effect to apply to the background. Default is nil.
    public var visualEffect: UIVisualEffect?
    /// The image to use. Default is nil.
    public var image: UIImage?
    /// The content mode to use when rendering the image. Default is UIViewContentModeScaleToFill.
    public var imageContentMode: UIView.ContentMode = .scaleToFill
    /// offset in user space of the shadow
    public var shadowOffset: CGSize = .zero
    /// blur radius of the shadow in default user space units
    public var shadowBlurRadius: CGFloat = 3
    /// color used for the shadow
    public var shadowColor: UIColor?
    
    public init(fillColor: UIColor? = nil,
         strokeColor: UIColor? = nil,
         strokeWidth: CGFloat = 0,
         strokeOutset: CGFloat = 0,
         cornerStyle: CornerStyle? = nil,
         stylishCorners: UIRectCorner = .allCorners,
         visualEffect: UIVisualEffect? = nil,
         image: UIImage? = nil,
         imageContentMode: UIView.ContentMode = .scaleToFill,
         shadowOffset: CGSize = .zero,
         shadowBlurRadius: CGFloat = 3,
         shadowColor: UIColor? = nil) {
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.strokeOutset = strokeOutset
        self.cornerStyle = cornerStyle
        self.stylishCorners = stylishCorners
        self.visualEffect = visualEffect
        self.image = image
        self.imageContentMode = imageContentMode
        self.shadowOffset = shadowOffset
        self.shadowBlurRadius = shadowBlurRadius
        self.shadowColor = shadowColor
    }
    
    public init() {}
}
