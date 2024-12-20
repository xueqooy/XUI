//
//  UIImageView+Convenience.swift
//  XUI
//
//  Created by xueqooy on 2023/9/13.
//

import UIKit

public extension UIImageView {
    convenience init(image: UIImage? = nil, contentMode: ContentMode = .scaleToFill, clipsToBounds: Bool = false, backgroundColor: UIColor? = nil, tintColor: UIColor? = nil) {
        self.init(image: image)

        self.contentMode = contentMode
        self.clipsToBounds = clipsToBounds
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
    }
}
