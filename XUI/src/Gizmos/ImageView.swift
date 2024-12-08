//
//  ImageView.swift
//  Pods
//
//  Created by xueqooy on 2024/12/4.
//

import UIKit

public struct ImageTransition: OptionSet {
    
    public static var fade = ImageTransition(rawValue: 1 << 0)
    public static var scale = ImageTransition(rawValue: 1 << 1)
    
    public var rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

open class ImageView: UIImageView {
    
    open override var image: UIImage? {
        didSet {
            guard image !== oldValue else { return }
        
            if let previousImage = oldValue?.cgImage, let currentImage = image?.cgImage, isVisible {
                if transition.contains(.fade) {
                    layer.animate(from: previousImage, to: currentImage, keyPath: "contents", duration: 0.2)
                }
                
                if transition.contains(.scale) {
                    layer.animateKeyframes(values: [NSNumber(value: 1.0), NSNumber(value: 0.5), NSNumber(value: 1.0)], duration: 0.2, keyPath: "transform.scale", mediaTimingFunctions: [
                        CAMediaTimingFunction(name: .easeIn),
                        CAMediaTimingFunction(name: .easeOut)
                    ])
                }
            }
        }
    }
    
    private var isVisible: Bool {
        alpha > 0.01 && !isHidden && window != nil
    }
    
    public var transition: ImageTransition = []
}
