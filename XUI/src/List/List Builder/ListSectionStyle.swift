//
//  ListSectionStyle.swift
//  XUI
//
//  Created by xueqooy on 2024/1/25.
//

import UIKit


public struct ListSectionStyle {
    
    public let inset: UIEdgeInsets
    public let minimumLineSpacing: CGFloat
    public let minimumInteritemSpacing: CGFloat
    
    public let backgroundConfiguration: BackgroundConfiguration?
    public let backgroundInset: Insets
    
    public init(inset: UIEdgeInsets = .zero, minimumLineSpacing: CGFloat = 0, minimumInteritemSpacing: CGFloat = 0, backgroundConfiguration: BackgroundConfiguration? = nil, backgroundInset: Insets = .nondirectionalZero) {
        self.inset = inset
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.backgroundConfiguration = backgroundConfiguration
        self.backgroundInset = backgroundInset
    }
}
