//
//  ButtonConfiguration.swift
//  XUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit
import XKit

public struct ButtonConfiguration: Equatable, Then {
    
    public enum ImagePlacement: Int, Equatable {
        case leading, trailing, top, left, bottom, right
    }
    
    public enum TitleAlignment: Int, Equatable {
        /// Align title & subtitle automatically based on ImagePlacement
        case automatic
        case leading, center, trailing, left, right
    }
    
    public var image: UIImage?
    public var imageSize: CGSize?
    
    // richTitle > title
    public var title: String?
    public var titleFont: UIFont?
    public var titleColor: UIColor?
    public var richTitle: RichText?
    
    // richSubtitle > subtitle
    public var subtitle: String?
    public var subtitleFont: UIFont?
    public var subtitleColor: UIColor?
    public var richSubtitle: RichText?
    
    /// Shows an activity indicator in place of an image. Its placement is controlled by `imagePlacement` .
    public var showsActivityIndicator: Bool = false
    public var indicatorSize: CGSize?

    /// Defaults to Leading.
    public var imagePlacement: ButtonConfiguration.ImagePlacement = .leading
    /// The alignment to use for relative layout between title & subtitle.
    public var titleAlignment: ButtonConfiguration.TitleAlignment = .automatic
    
    /// Insets from the bounds of the button to create the content region.
    public var contentInsets: Insets = .directionalZero
    
    /// When a button has both image and text content, this value is the padding between the image and the text.
    public var imagePadding: CGFloat = 0
    /// When a button has both a title & subtitle, this value is the padding between those titles.
    public var titlePadding: CGFloat = 0
        
    /// A BackgroundConfiguration describing the button's background.
    public var background: BackgroundConfiguration? = .init()
    
    /// The base color to use for foreground elements.
    public var foregroundColor: UIColor?

    public init(image: UIImage? = nil,
                imageSize: CGSize? = nil,
                title: String? = nil,
                titleFont: UIFont? = nil,
                titleColor: UIColor? = nil,
                richTitle: RichText? = nil,
                subtitle: String? = nil,
                subtitleFont: UIFont? = nil,
                subtitleColor: UIColor? = nil,
                richSubtitle: RichText? = nil,
                showsActivityIndicator: Bool = false,
                indicatorSize: CGSize? = nil,
                imagePlacement: ButtonConfiguration.ImagePlacement = .leading,
                titleAlignment: ButtonConfiguration.TitleAlignment = .automatic,
                contentInsets: Insets = .directionalZero,
                imagePadding: CGFloat = 0,
                titlePadding: CGFloat = 0,
                background: BackgroundConfiguration? = .init(),
                foregroundColor: UIColor? = nil) {
        self.image = image
        self.imageSize = imageSize
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.richTitle = richTitle
        self.subtitle = subtitle
        self.subtitleFont = subtitleFont
        self.subtitleColor = subtitleColor
        self.richSubtitle = richSubtitle
        self.showsActivityIndicator = showsActivityIndicator
        self.indicatorSize = indicatorSize
        self.imagePlacement = imagePlacement
        self.titleAlignment = titleAlignment
        self.contentInsets = contentInsets
        self.imagePadding = imagePadding
        self.titlePadding = titlePadding
        self.background = background
        self.foregroundColor = foregroundColor
    }
    
    public init() {
    }
}
