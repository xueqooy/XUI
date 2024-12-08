//
//  Button+Convenience.swift
//  XUI
//
//  Created by xueqooy on 2023/2/23.
//

import UIKit

public extension Button {
    
    typealias DesignedStyle = DesignedButtonConfigurationTransformer.Style
    typealias ContentInsetsMode = DesignedButtonConfigurationTransformer.ContentInsetsMode

    convenience init(
        designStyle: DesignedStyle,
        mainColor: UIColor = Colors.teal,
        alternativeBackgroundColor: UIColor = .clear,
        contentInsetsMode: ContentInsetsMode = .default,
        configuration: ButtonConfiguration = ButtonConfiguration(),
        width: CGFloat? = nil,
        touchUpInsideAction: ((Button) -> Void)? = nil) {
            
            self.init(configuration: configuration, configurationTransformer: DesignedButtonConfigurationTransformer(style: designStyle, mainColor: mainColor, alternativeBackgroundColor: alternativeBackgroundColor, contentInsetsMode: contentInsetsMode), touchUpInsideAction: touchUpInsideAction)
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    
    convenience init(
        designStyle: DesignedStyle,
        mainColor: UIColor = Colors.teal,
        alternativeBackgroundColor: UIColor = .clear,
        contentInsetsMode: ContentInsetsMode = .default,
        title: String? = nil,
        image: UIImage? = nil,
        width: CGFloat? = nil,
        touchUpInsideAction: ((Button) -> Void)? = nil) {
            
        let configuration = ButtonConfiguration(image: image, title: title)
        self.init(configuration: configuration, configurationTransformer: DesignedButtonConfigurationTransformer(style: designStyle, mainColor: mainColor, alternativeBackgroundColor: alternativeBackgroundColor, contentInsetsMode: contentInsetsMode), touchUpInsideAction: touchUpInsideAction)
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    
    convenience init(image: UIImage, imageSize: CGSize? = nil, foregroundColor: UIColor? = nil, touchUpInsideAction: ((Button) -> Void)? = nil) {
        let configuration = ButtonConfiguration(image: image, imageSize: imageSize, foregroundColor: foregroundColor)
        self.init(configuration: configuration, touchUpInsideAction: touchUpInsideAction)
    }
}
