//
//  Button.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/9/20.
//

import UIKit

/// The type that provide effective configuration for button.
public protocol ButtonConfigurationTransforming {
    
    var respondsToEnabledChanged: Bool { get }
    
    func resolvedConfiguration(for button: Button) -> ButtonConfiguration
}

public extension ButtonConfigurationTransforming {
    
    var respondsToEnabledChanged: Bool {
        false
    }
}


/// A configuration-based button.
///
/// All attributes can be set through `BackgroundConfiguration`.
/// `ButtonConfigurationTransforming` can be provided to transform configuration,
///
open class Button: UIControl, Configurable {
    /// The base configuration
    /// It's not used to represent the current UI state of the button, but the effective configuration is.
    open var configuration: ButtonConfiguration {
        didSet {
            guard configuration != oldValue else {
                return
            }
            
            updateConfiguration()
        }
    }
    
    /// The provider of effective configuration.
    /// If value is nil, always use base configuration as effective  configuration.
    open var configurationTransformer: ButtonConfigurationTransforming? {
        didSet {
            updateConfiguration()
        }
    }
    
    /// The convenience for `touchUpInside` action.
    open var touchUpInsideAction: ((Button) -> Void)?
    
    public init(configuration: ButtonConfiguration = ButtonConfiguration(), configurationTransformer: ButtonConfigurationTransforming? = PlainButtonConfigurationTransformer(), touchUpInsideAction: ((Button) -> Void)? = nil) {
        self.configuration = configuration
        self._effectiveConfiguration =  configuration
        self.configurationTransformer = configurationTransformer
        self.touchUpInsideAction = touchUpInsideAction
        
        super.init(frame: .zero)
        
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        let configuration = ButtonConfiguration()
        self.configuration = configuration
        self._effectiveConfiguration = configuration
        self.configurationTransformer = PlainButtonConfigurationTransformer()
        
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    private func initialize() {
        isAccessibilityElement = true
        accessibilityTraits.insert(.button)
        addTarget(self, action: #selector(touchUpInsideTriggered), for: .touchUpInside)
        
        updateConfiguration()
        
        // Add scale and highlighted effect when press the button
        let progressiveGestureRecognizer = ProgressivePressGestureRecognizer(maxPressDuration: 0.1, resetDuration: 0.1) { [weak self] progress in
            guard let self else { return }
            
            if progress == 0 {
                self.layer.sublayerTransform = CATransform3DIdentity
                self.subviews.forEach { $0.alpha = 1.0 }
                
            } else {
                let finalScale = 0.98
                let finalOpacity = 0.9
                
                let scale = (1.0 - progress) + finalScale * progress
                let opacity = (1.0 - progress) + finalOpacity * progress
                
                self.layer.sublayerTransform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0)
                self.subviews.forEach { $0.alpha = opacity }
            }
        }
        
        addGestureRecognizer(progressiveGestureRecognizer)
    }
    
    @objc private func touchUpInsideTriggered() {
        touchUpInsideAction?(self)
    }
    
    // MARK: - Update
    
    private var hasUpdatedOnce = false
        
    /// The configuration that represent the current UI state of the button.
    open var effectiveConfiguration: ButtonConfiguration {
        return _effectiveConfiguration
    }
    
    /// The configuration that represent the current UI state of the button (Internal use).
    private var _effectiveConfiguration: ButtonConfiguration {
        didSet {
            if _effectiveConfiguration == oldValue && hasUpdatedOnce {
                return
            }
            
            if !hasUpdatedOnce {
                updateForeground()
                updateBackground()
                layoutForeground()
                layoutBackground()
            } else {
                if _effectiveConfiguration.image != oldValue.image ||
                    _effectiveConfiguration.imageSize != oldValue.imageSize ||
                    _effectiveConfiguration.title != oldValue.title ||
                    _effectiveConfiguration.titleFont != oldValue.titleFont ||
                    _effectiveConfiguration.richTitle != oldValue.richTitle ||
                    _effectiveConfiguration.subtitle != oldValue.subtitle ||
                    _effectiveConfiguration.subtitleFont != oldValue.subtitleFont ||
                    _effectiveConfiguration.richSubtitle != oldValue.richSubtitle ||
                    _effectiveConfiguration.showsActivityIndicator != oldValue.showsActivityIndicator ||
                    _effectiveConfiguration.indicatorSize != oldValue.indicatorSize ||
                    _effectiveConfiguration.contentInsets != oldValue.contentInsets ||
                    _effectiveConfiguration.imagePlacement != oldValue.imagePlacement ||
                    _effectiveConfiguration.titleAlignment != oldValue.titleAlignment ||
                    _effectiveConfiguration.contentInsets != oldValue.contentInsets ||
                    _effectiveConfiguration.imagePadding != oldValue.imagePadding ||
                    _effectiveConfiguration.titlePadding != oldValue.titlePadding ||
                    _effectiveConfiguration.foregroundColor != oldValue.foregroundColor ||
                        _effectiveConfiguration.titleColor != oldValue.titleColor ||
                        _effectiveConfiguration.subtitleColor != oldValue.subtitleColor {
                    
                    updateForeground()
                    layoutForeground()
                }
        
                if _effectiveConfiguration.background != oldValue.background {
                    updateBackground()
                    layoutBackground()
                }
            }
            
            hasUpdatedOnce = true
        }
    }
    
    /// Update button's `effectiveConfiguration`
    open func updateConfiguration() {
        _effectiveConfiguration = configurationTransformer?.resolvedConfiguration(for: self) ?? configuration
    }
    
    private func updateBackground() {
        if shouldDisplayBackground {
            backgroundView.configuration = _effectiveConfiguration.background ?? BackgroundConfiguration()
        }
    }
    
    /// Update foreground elements, except for color.
    private func updateForeground() {
        let foregroundColor = _effectiveConfiguration.foregroundColor
        
        var textAlignment: NSTextAlignment = .natural
        switch effectiveTitleAlignment {
        case .left:
            textAlignment = .left
        case .right:
            textAlignment = .right
        case .center:
            textAlignment = .center
        default: break
        }
        
        if shouldDisplayImage {
            imageView.tintColor = foregroundColor
            imageView.image = _effectiveConfiguration.image
        }
        
        if shouldDisplayActivityIndicator {
            activityIndicatorView.indicatorColor = foregroundColor
            activityIndicatorView.startAnimating()
        }
        
        var accessibilityLabels = [String]()
        
        if shouldDisplayTitle {
            titleLabel.textColor = _effectiveConfiguration.titleColor ?? foregroundColor
            titleLabel.font = _effectiveConfiguration.titleFont ?? .preferredFont(forTextStyle: .headline)
            titleLabel.textAlignment = textAlignment
            
            if let richTitle = _effectiveConfiguration.richTitle {
                titleLabel.richText = richTitle
                
                accessibilityLabels.append(richTitle.attributedString.string)
                
            } else if let title = _effectiveConfiguration.title {
                titleLabel.text = title

                accessibilityLabels.append(title)
            }
        } else {
            accessibilityLabel = nil
        }
        
        if shouldDisplaySubtitle  {
            subtitleLabel.textColor = _effectiveConfiguration.subtitleColor ?? foregroundColor
            subtitleLabel.font = _effectiveConfiguration.subtitleFont ?? .preferredFont(forTextStyle: .subheadline)
            subtitleLabel.textAlignment = textAlignment
            
            if let richSubtitle = _effectiveConfiguration.richSubtitle {
                subtitleLabel.richText = richSubtitle
                
                accessibilityLabels.append(richSubtitle.attributedString.string)
                
            } else if let subtitle = _effectiveConfiguration.subtitle {
                subtitleLabel.text = subtitle
                
                accessibilityLabels.append(subtitle)
            }
        }
        
        if !accessibilityLabels.isEmpty {
            accessibilityLabel = accessibilityLabels.joined(separator: ", ")
        } else {
            accessibilityLabel = nil
        }
    }
    
    
    // MARK: - Layout
    
    // Determine the actual layout parameters based on configuration.
        
    private var shouldDisplayBackground: Bool {
        _effectiveConfiguration.background != nil
    }
    
    private var shouldDisplayImage: Bool {
        _effectiveConfiguration.showsActivityIndicator ? false : _effectiveConfiguration.image != nil
    }
    
    private var shouldDisplayActivityIndicator: Bool {
        _effectiveConfiguration.showsActivityIndicator
    }
    
    private var shouldDisplayTitle: Bool {
        if let richTitle = _effectiveConfiguration.richTitle {
            return richTitle.length > 0
        }
        if let title = _effectiveConfiguration.title{
            return !title.isEmpty
        }
        return false
    }
    private var shouldDisplaySubtitle: Bool {
        if let richSubtitle = _effectiveConfiguration.richSubtitle {
            return richSubtitle.length > 0
        }
        if let subtitle = _effectiveConfiguration.subtitle {
            return !subtitle.isEmpty
        }
        return false
    }
    
    private var effectiveImagePlacement: ButtonConfiguration.ImagePlacement {
        switch _effectiveConfiguration.imagePlacement {
        case .leading:
            return layoutDirectionIsRTL ? .right : .left
        case .trailing:
            return layoutDirectionIsRTL ? .left : .right
        default:
            return _effectiveConfiguration.imagePlacement
        }
    }
    
    private var effectiveTitleAlignment: ButtonConfiguration.TitleAlignment {
        switch _effectiveConfiguration.titleAlignment {
        case .leading:
            return layoutDirectionIsRTL ? .right : .left
        case .trailing:
            return layoutDirectionIsRTL ? .left : .right
        case .automatic:
            if shouldDisplayImage {
                switch _effectiveConfiguration.imagePlacement {
                case .leading:
                    return layoutDirectionIsRTL ? .right : .left
                case .trailing:
                    return layoutDirectionIsRTL ? .left : .right
                case .top, .bottom:
                    return .center
                case .left:
                    return .left
                case .right:
                    return .right
                }
            } else {
                return layoutDirectionIsRTL ? .right : .left
            }
        default:
            return _effectiveConfiguration.titleAlignment
        }
    }
    
    private var effectiveContentInsets: UIEdgeInsets {
        _effectiveConfiguration.contentInsets.edgeInsets(for: effectiveUserInterfaceLayoutDirection)
    }

    private var didAddBackgroundView = false
    private var didAddImageView = false
    private var didAddTitleView = false
    private var didAddSubtitleView = false
    private var didAddActivityIndicatorView = false
    
    private func layoutBackground() {
        if shouldDisplayBackground {
            self.backgroundView.frame = bounds
          
            if !backgroundView.isDescendant(of: self) {
                addSubview(backgroundView)
                didAddBackgroundView = true
            }
            sendSubviewToBack(backgroundView)
        } else if didAddBackgroundView {
            backgroundView.removeFromSuperview()
            didAddBackgroundView = false
        }
    }
    
    private func layoutForeground() {
        if shouldDisplayImage {
            if !imageView.isDescendant(of: self) {
                addSubview(imageView)
            }
            didAddImageView = true
        } else if didAddImageView {
            imageView.removeFromSuperview()
            didAddImageView = false
        }
        
        if shouldDisplayActivityIndicator {
            if !activityIndicatorView.isDescendant(of: self) {
                addSubview(activityIndicatorView)
            }
            didAddActivityIndicatorView = true
        } else if didAddActivityIndicatorView {
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            didAddActivityIndicatorView = false
        }
        
        if shouldDisplayTitle {
            if !titleLabel.isDescendant(of: self) {
                addSubview(titleLabel)
            }
            didAddTitleView = true
        } else if didAddTitleView {
            titleLabel.removeFromSuperview()
            didAddTitleView = false
        }
        
        if shouldDisplaySubtitle  {
            if !subtitleLabel.isDescendant(of: self) {
                addSubview(subtitleLabel)
            }
            didAddSubtitleView = true
        } else if didAddSubtitleView {
            subtitleLabel.removeFromSuperview()
            didAddSubtitleView = false
        }
        
        // layout priority: image/activityIndicator -> title -> subtitle
                
        let effectiveImagePlacement = self.effectiveImagePlacement
        let effectiveTitleAlignment = self.effectiveTitleAlignment
        let effectiveContentInsets = self.effectiveContentInsets
        let effectiveContentHorizontalAlignment = self.effectiveContentHorizontalAlignment

        let contentSize = CGSize(width: bounds.width - effectiveContentInsets.horizontal, height: bounds.height - effectiveContentInsets.vertical).eraseNegative()

        let shouldDisplayActivityIndicator = self.shouldDisplayActivityIndicator
        let shouldDisplayImage = self.shouldDisplayImage
        let shouldDisplayImageOrActivityIndicator = shouldDisplayActivityIndicator || shouldDisplayImage
        let shouldDisplayTitle = self.shouldDisplayTitle
        let shouldDisplaySubtitle = self.shouldDisplaySubtitle
    
        let imagePadding = shouldDisplayImageOrActivityIndicator && (shouldDisplayTitle || shouldDisplaySubtitle) ? _effectiveConfiguration.imagePadding : 0
        let titlePadding = shouldDisplayTitle && shouldDisplaySubtitle ? _effectiveConfiguration.titlePadding : 0
                
        var imageOrActivityIndicatorFrame = CGRect.zero
        var titleFrame = CGRect.zero
        var subtitleFrame = CGRect.zero
        
        var imageOrIndicatorLimitSize = CGSize.zero
        var titleLimitSize = CGSize.zero
        var subtitleLimitSize = CGSize.zero
        
        imageOrIndicatorLimitSize = contentSize
        if shouldDisplayActivityIndicator {
            imageOrActivityIndicatorFrame.size = (_effectiveConfiguration.indicatorSize ?? activityIndicatorView.sizeThatFits(imageOrIndicatorLimitSize)).limit(to: imageOrIndicatorLimitSize)
        } else if shouldDisplayImage {
            imageOrActivityIndicatorFrame.size = (_effectiveConfiguration.imageSize ?? imageView.sizeThatFits(imageOrIndicatorLimitSize)).limit(to: imageOrIndicatorLimitSize)
        }
        
        switch effectiveImagePlacement {
        case .top, .bottom:
            if shouldDisplayTitle {
                titleLimitSize = CGSize(width: contentSize.width, height: contentSize.height - imageOrActivityIndicatorFrame.height - imagePadding).eraseNegative()
                titleFrame.size = titleLabel.sizeThatFits(titleLimitSize).limit(to: titleLimitSize)
            }
            if shouldDisplaySubtitle {
                subtitleLimitSize = CGSize(width: contentSize.width, height: contentSize.height - imageOrActivityIndicatorFrame.height - imagePadding - titleFrame.height - titlePadding).eraseNegative()
                subtitleFrame.size = subtitleLabel.sizeThatFits(subtitleLimitSize).limit(to: subtitleLimitSize)
            }

            switch effectiveContentHorizontalAlignment {
            case .left:
                let maxContentWidth = max(imageOrActivityIndicatorFrame.width, max(titleFrame.width, subtitleFrame.width))
                
                if shouldDisplayImageOrActivityIndicator {
                    imageOrActivityIndicatorFrame.origin.x = effectiveContentInsets.left + (maxContentWidth - imageOrActivityIndicatorFrame.width) / 2
                }
                if shouldDisplayTitle {
                    titleFrame.origin.x = effectiveContentInsets.left + (maxContentWidth - titleFrame.width) / 2
                }
                if shouldDisplaySubtitle {
                    subtitleFrame.origin.x = effectiveContentInsets.left + (maxContentWidth - subtitleFrame.width) / 2
                }
            case .center:
                if shouldDisplayImageOrActivityIndicator {
                    imageOrActivityIndicatorFrame.origin.x = effectiveContentInsets.left + (imageOrIndicatorLimitSize.width - imageOrActivityIndicatorFrame.width) / 2
                }
                if shouldDisplayTitle {
                    titleFrame.origin.x = effectiveContentInsets.left + (titleLimitSize.width - titleFrame.width) / 2
                }
                if shouldDisplaySubtitle {
                    subtitleFrame.origin.x = effectiveContentInsets.left + (subtitleLimitSize.width - subtitleFrame.width) / 2
                }
            case .right:
                let maxContentWidth = max(imageOrActivityIndicatorFrame.width, max(titleFrame.width, subtitleFrame.width))

                if shouldDisplayImageOrActivityIndicator {
                    imageOrActivityIndicatorFrame.origin.x = bounds.width - effectiveContentInsets.right - imageOrActivityIndicatorFrame.width - (maxContentWidth - imageOrActivityIndicatorFrame.width) / 2
                }
                if shouldDisplayTitle {
                    titleFrame.origin.x = bounds.width - effectiveContentInsets.right - titleFrame.width - (maxContentWidth - titleFrame.width) / 2
                }
                if shouldDisplaySubtitle {
                    subtitleFrame.origin.x = bounds.width - effectiveContentInsets.right - subtitleFrame.width - (maxContentWidth - subtitleFrame.width) / 2
                }
            case .fill:
                if shouldDisplayImageOrActivityIndicator {
                    imageOrActivityIndicatorFrame.origin.x = effectiveContentInsets.left
                    imageOrActivityIndicatorFrame.size.width = imageOrIndicatorLimitSize.width
                }
                if shouldDisplayTitle {
                    titleFrame.origin.x = effectiveContentInsets.left
                    titleFrame.size.width = titleLimitSize.width
                }
                if shouldDisplaySubtitle {
                    subtitleFrame.origin.x = effectiveContentInsets.left
                    subtitleFrame.size.width = subtitleLimitSize.width
                }
            default: break
            }
            
            if effectiveImagePlacement == .top {
                switch contentVerticalAlignment {
                case .top:
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.y = effectiveContentInsets.top
                    }
                    if shouldDisplayTitle {
                        titleFrame.origin.y = effectiveContentInsets.top + imageOrActivityIndicatorFrame.height + imagePadding
                    }
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.y = effectiveContentInsets.top + imageOrActivityIndicatorFrame.height + imagePadding + titleFrame.height + titlePadding
                    }
                case .center:
                    let contentHeight = imageOrActivityIndicatorFrame.height + imagePadding + titleFrame.height + titlePadding + subtitleFrame.height
                    let minY = effectiveContentInsets.top + (contentSize.height - contentHeight) / 2
                  
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.y = minY
                    }
                    if shouldDisplayTitle {
                        titleFrame.origin.y = minY + imageOrActivityIndicatorFrame.height + imagePadding
                    }
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.y = minY + imageOrActivityIndicatorFrame.height + imagePadding + titleFrame.height + titlePadding
                    }
                case .bottom:
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.y = bounds.height - effectiveContentInsets.bottom - subtitleFrame.height
                    }
                    if shouldDisplayTitle {
                        titleFrame.origin.y = bounds.height - effectiveContentInsets.bottom - subtitleFrame.height - titlePadding - titleFrame.height
                    }
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.y = bounds.height - effectiveContentInsets.bottom - subtitleFrame.height - titlePadding - titleFrame.height - imagePadding - imageOrActivityIndicatorFrame.height
                    }
                case .fill:
                    if shouldDisplayImageOrActivityIndicator && (shouldDisplayTitle || shouldDisplaySubtitle) {
                        // Layout image first, the remaining space is reserved for title
                        imageOrActivityIndicatorFrame.origin.y = effectiveContentInsets.top
                        if shouldDisplayTitle {
                            titleFrame.origin.y = effectiveContentInsets.top + imageOrActivityIndicatorFrame.height + imagePadding
                            if !shouldDisplaySubtitle {
                                titleFrame.size.height = max(bounds.height - titleFrame.minY - effectiveContentInsets.bottom, 0)
                            }
                        }
                        if shouldDisplaySubtitle {
                            subtitleFrame.origin.y = effectiveContentInsets.top + imageOrActivityIndicatorFrame.height + imagePadding + titleFrame.height + titlePadding
                            subtitleFrame.size.height = max(bounds.height - subtitleFrame.minY - effectiveContentInsets.bottom, 0)
                        }
                    } else if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.y = effectiveContentInsets.top
                        imageOrActivityIndicatorFrame.size.height = contentSize.height
                    } else {
                        if shouldDisplayTitle {
                            titleFrame.origin.y = effectiveContentInsets.top
                            if !shouldDisplaySubtitle {
                                titleFrame.size.height = contentSize.height
                            }
                        }
                        if shouldDisplaySubtitle {
                            subtitleFrame.origin.y = effectiveContentInsets.top + titleFrame.height + titlePadding
                            subtitleFrame.size.height = max(bounds.height - subtitleFrame.minY - effectiveContentInsets.bottom, 0)
                        }
                    }
                default: break
                }
            } else {
                switch contentVerticalAlignment {
                case .top:
                    if shouldDisplayTitle {
                        titleFrame.origin.y = effectiveContentInsets.top
                    }
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.y = effectiveContentInsets.top + titleFrame.height + titlePadding
                    }
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.y = effectiveContentInsets.top + titleFrame.height + titlePadding + subtitleFrame.height + imagePadding
                    }
                case .center:
                    let contentHeight = imageOrActivityIndicatorFrame.height + imagePadding + titleFrame.height + titlePadding + subtitleFrame.height
                    let minY = effectiveContentInsets.top + (contentSize.height - contentHeight) / 2
                  
                    if shouldDisplayTitle {
                        titleFrame.origin.y = minY
                    }
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.y = minY + titleFrame.height + titlePadding
                    }
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.y = minY + titleFrame.height + titlePadding + subtitleFrame.height + imagePadding
                    }
                case .bottom:
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.y = bounds.height - effectiveContentInsets.bottom - imageOrActivityIndicatorFrame.height
                    }
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.y = bounds.height - effectiveContentInsets.bottom - imageOrActivityIndicatorFrame.height - imagePadding - subtitleFrame.height
                    }
                    if shouldDisplayTitle {
                        titleFrame.origin.y = bounds.height - effectiveContentInsets.bottom - imageOrActivityIndicatorFrame.height - imagePadding - subtitleFrame.height - titlePadding - titleFrame.height
                    }
                case .fill:
                    if shouldDisplayImageOrActivityIndicator && (shouldDisplayTitle || shouldDisplaySubtitle) {
                        // Layout image first, the remaining space is reserved for title
                        imageOrActivityIndicatorFrame.origin.y = bounds.height - effectiveContentInsets.top - imageOrActivityIndicatorFrame.height
                        if shouldDisplayTitle {
                            titleFrame.origin.y = effectiveContentInsets.top
                            if !shouldDisplaySubtitle {
                                titleFrame.size.height = max(bounds.height - titleFrame.minY - imagePadding - imageOrActivityIndicatorFrame.height - effectiveContentInsets.bottom, 0)
                            }
                        }
                        if shouldDisplaySubtitle {
                            subtitleFrame.origin.y = effectiveContentInsets.top + titleFrame.height + titlePadding
                            subtitleFrame.size.height = max(bounds.height - subtitleFrame.minY - imagePadding - imageOrActivityIndicatorFrame.height - effectiveContentInsets.bottom, 0)
                        }
                    } else if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.y = effectiveContentInsets.top
                        imageOrActivityIndicatorFrame.size.height = contentSize.height
                    } else {
                        if shouldDisplayTitle {
                            titleFrame.origin.y = effectiveContentInsets.top
                            if !shouldDisplaySubtitle {
                                titleFrame.size.height = contentSize.height
                            }
                        }
                        if shouldDisplaySubtitle {
                            subtitleFrame.origin.y = effectiveContentInsets.top + titleFrame.height + titlePadding
                            subtitleFrame.size.height = max(bounds.height - subtitleFrame.minY - effectiveContentInsets.bottom, 0)
                        }
                    }
                default: break
                }
            }

        case .left, .right:
            if shouldDisplayTitle {
                titleLimitSize = CGSize(width: contentSize.width - imageOrActivityIndicatorFrame.width - imagePadding, height: contentSize.height).eraseNegative()
                titleFrame.size = titleLabel.sizeThatFits(titleLimitSize).limit(to: titleLimitSize)
            }
            if shouldDisplaySubtitle {
                subtitleLimitSize = CGSize(width: contentSize.width - imageOrActivityIndicatorFrame.width - imagePadding, height: contentSize.height - titleFrame.height - titlePadding).eraseNegative()
                subtitleFrame.size = subtitleLabel.sizeThatFits(subtitleLimitSize).limit(to: subtitleLimitSize)
            }
            
            switch contentVerticalAlignment {
            case .top:
                let titleTotalHeight = titleFrame.height + titlePadding + subtitleFrame.height
                let maxContentHeight = max(imageOrActivityIndicatorFrame.height, titleTotalHeight)
                
                if shouldDisplayImageOrActivityIndicator {
                    imageOrActivityIndicatorFrame.origin.y = effectiveContentInsets.top + (maxContentHeight - imageOrActivityIndicatorFrame.height) / 2
                }
                if shouldDisplayTitle {
                    titleFrame.origin.y = effectiveContentInsets.top + (maxContentHeight - titleTotalHeight) / 2
                }
                if shouldDisplaySubtitle {
                    subtitleFrame.origin.y = effectiveContentInsets.top + (maxContentHeight - titleTotalHeight) / 2 + titleFrame.height + titlePadding
                }
            case .center:
                if shouldDisplayImageOrActivityIndicator {
                    imageOrActivityIndicatorFrame.origin.y = effectiveContentInsets.top + (contentSize.height - imageOrActivityIndicatorFrame.height) / 2
                }
                
                let titleTotalHeight = titleFrame.height + titlePadding + subtitleFrame.height
                let minY = effectiveContentInsets.top + (contentSize.height - titleTotalHeight) / 2
            
                if shouldDisplayTitle {
                    titleFrame.origin.y = minY
                }
                if shouldDisplaySubtitle {
                    subtitleFrame.origin.y = minY + titleFrame.height + titlePadding
                }
            case .bottom:
                let titleTotalHeight = titleFrame.height + titlePadding + subtitleFrame.height
                let maxContentHeight = max(imageOrActivityIndicatorFrame.height, titleTotalHeight)
                
                if shouldDisplayImageOrActivityIndicator {
                    imageOrActivityIndicatorFrame.origin.y = bounds.height - effectiveContentInsets.bottom - imageOrActivityIndicatorFrame.height - (maxContentHeight - imageOrActivityIndicatorFrame.height) / 2
                }
                if shouldDisplaySubtitle {
                    subtitleFrame.origin.y = bounds.height - effectiveContentInsets.bottom - subtitleFrame.height - (maxContentHeight - titleTotalHeight) / 2
                }
                if shouldDisplayTitle {
                    titleFrame.origin.y = bounds.height - effectiveContentInsets.bottom - subtitleFrame.height - titlePadding - titleFrame.height - (maxContentHeight - titleTotalHeight) / 2
                }
            case .fill:
                if shouldDisplayImageOrActivityIndicator {
                    imageOrActivityIndicatorFrame.origin.y = effectiveContentInsets.top
                    imageOrActivityIndicatorFrame.size.height = contentSize.height
                }
                if shouldDisplayTitle {
                    titleFrame.origin.y = effectiveContentInsets.top
                    if !shouldDisplaySubtitle {
                        titleFrame.size.height = contentSize.height
                    }
                }
                if shouldDisplaySubtitle {
                    subtitleFrame.origin.y = effectiveContentInsets.top + titleFrame.height + titlePadding
                    subtitleFrame.size.height = max(bounds.height - subtitleFrame.minY - effectiveContentInsets.bottom, 0)
                }
            default: break
            }
            
            if effectiveImagePlacement == .left {
                switch effectiveContentHorizontalAlignment {
                case .left:
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.x = effectiveContentInsets.left
                    }
                    if shouldDisplayTitle {
                        titleFrame.origin.x = effectiveContentInsets.left + imageOrActivityIndicatorFrame.width + imagePadding
                    }
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.x = effectiveContentInsets.left + imageOrActivityIndicatorFrame.width + imagePadding
                    }
                case .center:
                    let contentWidth = imageOrActivityIndicatorFrame.width + imagePadding + max(titleFrame.width, subtitleFrame.width)
                    let minX = effectiveContentInsets.left + (contentSize.width - contentWidth) / 2
                    
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.x = minX
                    }
                    if shouldDisplayTitle {
                        titleFrame.origin.x = minX + imageOrActivityIndicatorFrame.width + imagePadding
                    }
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.x = minX + imageOrActivityIndicatorFrame.width + imagePadding
                    }
                case .right:
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.x = bounds.width - effectiveContentInsets.right - max(titleFrame.width, subtitleFrame.width) - imagePadding - imageOrActivityIndicatorFrame.width
                    }
                    if shouldDisplayTitle {
                        titleFrame.origin.x = bounds.width - effectiveContentInsets.right - titleFrame.width
                    }
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.x = bounds.width - effectiveContentInsets.right - subtitleFrame.width
                    }
                case .fill:
                    if shouldDisplayImageOrActivityIndicator && (shouldDisplayTitle || shouldDisplaySubtitle) {
                        // Layout image first, the remaining space is reserved for title
                        imageOrActivityIndicatorFrame.origin.x = effectiveContentInsets.left
                        if shouldDisplayTitle {
                            titleFrame.origin.x = effectiveContentInsets.left + imageOrActivityIndicatorFrame.width + imagePadding
                            titleFrame.size.width = contentSize.width - imagePadding - imageOrActivityIndicatorFrame.width
                        }
                        if shouldDisplaySubtitle {
                            subtitleFrame.origin.x = effectiveContentInsets.left + imageOrActivityIndicatorFrame.width + imagePadding
                            subtitleFrame.size.width = contentSize.width - imagePadding - imageOrActivityIndicatorFrame.width
                        }
                    } else if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.x = effectiveContentInsets.left
                        imageOrActivityIndicatorFrame.size.width = contentSize.width
                    } else {
                        if shouldDisplayTitle {
                            titleFrame.origin.x = effectiveContentInsets.left
                            titleFrame.size.width = contentSize.width
                        }
                        if shouldDisplaySubtitle {
                            subtitleFrame.origin.x = effectiveContentInsets.left
                            subtitleFrame.size.width = contentSize.width
                        }
                    }
                default: break
                }
            } else {
                switch effectiveContentHorizontalAlignment {
                case .left:
                    if shouldDisplayTitle {
                        titleFrame.origin.x = effectiveContentInsets.left
                    }
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.x = effectiveContentInsets.left
                    }
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.x = effectiveContentInsets.left + max(titleFrame.width, subtitleFrame.width) + imagePadding
                    }
                case .center:
                    let contentWidth = imageOrActivityIndicatorFrame.width + imagePadding + max(titleFrame.width, subtitleFrame.width)
                    let minX = effectiveContentInsets.left + (contentSize.width - contentWidth) / 2
                    
                    if shouldDisplayTitle {
                        titleFrame.origin.x = minX
                    }
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.x = minX
                    }
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.x = minX + max(titleFrame.width, subtitleFrame.width) + imagePadding
                    }
                case .right:
                    if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.x = bounds.width - effectiveContentInsets.right - imageOrActivityIndicatorFrame.width
                    }
                    if shouldDisplayTitle {
                        titleFrame.origin.x = bounds.width - effectiveContentInsets.right - imageOrActivityIndicatorFrame.width - imagePadding - titleFrame.width
                    }
                    if shouldDisplaySubtitle {
                        subtitleFrame.origin.x = bounds.width - effectiveContentInsets.right - imageOrActivityIndicatorFrame.width - imagePadding - subtitleFrame.width
                    }
                case .fill:
                    if shouldDisplayImageOrActivityIndicator && (shouldDisplayTitle || shouldDisplaySubtitle) {
                        // Layout image first, the remaining space is reserved for title
                        imageOrActivityIndicatorFrame.origin.x = bounds.width - effectiveContentInsets.right - imageOrActivityIndicatorFrame.width
                        if shouldDisplayTitle {
                            titleFrame.origin.x = effectiveContentInsets.left
                            titleFrame.size.width = imageOrActivityIndicatorFrame.minX - imagePadding - titleFrame.minX
                        }
                        if shouldDisplaySubtitle {
                            subtitleFrame.origin.x = effectiveContentInsets.left
                            subtitleFrame.size.width = imageOrActivityIndicatorFrame.minX - imagePadding - titleFrame.minX
                        }
                    } else if shouldDisplayImageOrActivityIndicator {
                        imageOrActivityIndicatorFrame.origin.x = effectiveContentInsets.left
                        imageOrActivityIndicatorFrame.size.width = contentSize.width
                    } else {
                        if shouldDisplayTitle {
                            titleFrame.origin.x = effectiveContentInsets.left
                            titleFrame.size.width = contentSize.width
                        }
                        if shouldDisplaySubtitle {
                            subtitleFrame.origin.x = effectiveContentInsets.left
                            subtitleFrame.size.width = contentSize.width
                        }
                    }
                default: break
                }
            }
        default: break
        }

        // Adjust frame based on title alignment
        if shouldDisplayTitle && shouldDisplaySubtitle && titleFrame.width != subtitleFrame.width {
            let isSubtitleFrameUpdated: Bool
            let widerFrame: CGRect
            var updatedFrame: CGRect
            
            if titleFrame.width > subtitleFrame.width {
                isSubtitleFrameUpdated = true
                widerFrame = titleFrame
                updatedFrame = subtitleFrame
            } else {
                isSubtitleFrameUpdated = false
                widerFrame = subtitleFrame
                updatedFrame = titleFrame
            }
        
            switch effectiveTitleAlignment {
            case .left:
                updatedFrame.origin.x = widerFrame.origin.x
            case .center:
                updatedFrame.origin.x = widerFrame.midX - updatedFrame.width / 2
            case .right:
                updatedFrame.origin.x = widerFrame.maxX - updatedFrame.width
            default: break
            }
            
            if isSubtitleFrameUpdated {
                subtitleFrame = updatedFrame
            } else {
                titleFrame = updatedFrame
            }
        }
        
        if shouldDisplayActivityIndicator {
            activityIndicatorView.frame = imageOrActivityIndicatorFrame
        } else if shouldDisplayImage {
            imageView.frame = imageOrActivityIndicatorFrame
        }
        if shouldDisplayTitle {
            titleLabel.frame = titleFrame
        }
        if shouldDisplaySubtitle {
            subtitleLabel.frame = subtitleFrame
        }
        
        bestSize = nil
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - UI Elements
    
    /// After setting, it can only be called once at most, reassign to refresh the indicator.
    /// A nil value uses `UIActivityIndicatorView`
    open var activityIndicatorProvider: (() -> ButtonActivityIndicator)? {
        didSet {
            if oldValue == nil && activityIndicatorProvider == nil { return }
            
            currentActivityIndicatorView?.removeFromSuperview()
            currentActivityIndicatorView = nil
            
            if shouldDisplayActivityIndicator {
                updateForeground()
                layoutForeground()
            }
        }
    }
    
    private var currentActivityIndicatorView: ButtonActivityIndicator?
    
    private var activityIndicatorView: ButtonActivityIndicator {
        if let currentActivityIndicatorView = currentActivityIndicatorView {
            return currentActivityIndicatorView
        }
        
        let activityIndicatorView = activityIndicatorProvider?() ?? UIActivityIndicatorView()
        activityIndicatorView.indicatorColor = _effectiveConfiguration.foregroundColor
        currentActivityIndicatorView = activityIndicatorView
        return activityIndicatorView
    }

    
    private lazy var backgroundView: BackgroundView = {
        let backgroundView = BackgroundView()
        return backgroundView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = _effectiveConfiguration.foregroundColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = _effectiveConfiguration.titleColor ?? _effectiveConfiguration.foregroundColor
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.textColor = _effectiveConfiguration.subtitleColor ?? _effectiveConfiguration.foregroundColor
        subtitleLabel.numberOfLines = 0
        return subtitleLabel
    }()
    
    
    // MARK: - Size
    
    // Support for constraint-based layout (auto layout)
    // If not nil, this is used when determining -intrinsicContentSize
    open var preferredMaxLayoutWidthProvider: (() -> CGFloat)? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    private var bestSize: CGSize?
    private var isFittingSize: Bool = false
    
    open override func updateConstraints() {
        super.updateConstraints()
        invalidateIntrinsicContentSize()
    }

    open override var intrinsicContentSize: CGSize {
        if let preferredMaxLayoutWidthProvider = preferredMaxLayoutWidthProvider {
            let limitWidth = preferredMaxLayoutWidthProvider()
            return sizeThatFits(CGSize(width: limitWidth, height: .greatestFiniteMagnitude))
        } else {
            return sizeThatFits(.max)
        }
    }
    
    /// Always set the appropriate size.
    open override func sizeToFit() {
        isFittingSize = true
        super.sizeToFit()
        isFittingSize = false
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var limitSize = size
        if bounds.size.equalTo(size) && isFittingSize {
            limitSize = CGSize.max
        }
        
        // return cached size
        if let bestSize = bestSize, limitSize == CGSize.max {
            return bestSize
        }
        
        var resultSize = CGSize.zero
        
        let shouldDisplayActivityIndicator = self.shouldDisplayActivityIndicator
        let shouldDisplayImage = self.shouldDisplayImage
        let shouldDisplayImageOrActivityIndicator = shouldDisplayActivityIndicator || shouldDisplayImage
        let shouldDisplayTitle = self.shouldDisplayTitle
        let shouldDisplaySubtitle = self.shouldDisplaySubtitle
        
        let imagePadding = shouldDisplayImageOrActivityIndicator && (shouldDisplayTitle || shouldDisplaySubtitle) ? _effectiveConfiguration.imagePadding : 0
        let titlePadding = shouldDisplayTitle && shouldDisplaySubtitle ? _effectiveConfiguration.titlePadding : 0
        
        let horizontalInset: CGFloat = _effectiveConfiguration.contentInsets.horizontal
        let verticalInset: CGFloat = _effectiveConfiguration.contentInsets.vertical
        
        let contentLimitSize = CGSize(width: limitSize.width - horizontalInset, height: limitSize.height - verticalInset).eraseNegative()
        var imageOrActivityIndicatorSize = CGSize.zero
        var titleSize = CGSize.zero
        var subtitleSize = CGSize.zero
        
        switch effectiveImagePlacement {
        case .top, .bottom:
            if shouldDisplayImageOrActivityIndicator {
                let imageOrActivityIndicatorLimitSize = CGSize(width: contentLimitSize.width, height: CGFloat.greatestFiniteMagnitude)
                if shouldDisplayActivityIndicator {
                    imageOrActivityIndicatorSize = (_effectiveConfiguration.indicatorSize ?? activityIndicatorView.sizeThatFits(imageOrActivityIndicatorLimitSize)).limit(to: imageOrActivityIndicatorLimitSize)
                } else if shouldDisplayImage {
                    imageOrActivityIndicatorSize = (_effectiveConfiguration.imageSize ?? imageView.sizeThatFits(imageOrActivityIndicatorLimitSize)).limit(to: imageOrActivityIndicatorLimitSize)
                }
            }
            if shouldDisplayTitle {
                let titleLimitSize = CGSize(width: contentLimitSize.width, height: contentLimitSize.height - imageOrActivityIndicatorSize.height - imagePadding).eraseNegative()
                titleSize = titleLabel.sizeThatFits(titleLimitSize)
                titleSize.height = min(titleSize.height, titleLimitSize.height)
            }
            if shouldDisplaySubtitle {
                let subtitleLimitSize = CGSize(width: contentLimitSize.width, height: contentLimitSize.height - imageOrActivityIndicatorSize.height - imagePadding - titleSize.height - titlePadding).eraseNegative()
                subtitleSize = subtitleLabel.sizeThatFits(subtitleLimitSize)
                subtitleSize.height = min(subtitleSize.height, subtitleLimitSize.height)
            }
            resultSize.width = horizontalInset + max(imageOrActivityIndicatorSize.width, max(titleSize.width, subtitleSize.width))
            resultSize.height = verticalInset + imageOrActivityIndicatorSize.height + imagePadding + titleSize.height + titlePadding + subtitleSize.height
        case .left, .right, .leading, .trailing:
            if shouldDisplayImageOrActivityIndicator {
                let imageOrActivityIndicatorLimitSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: contentLimitSize.height)
                if shouldDisplayActivityIndicator {
                    imageOrActivityIndicatorSize = (_effectiveConfiguration.indicatorSize ?? activityIndicatorView.sizeThatFits(imageOrActivityIndicatorLimitSize)).limit(to: imageOrActivityIndicatorLimitSize)
                } else if shouldDisplayImage {
                    imageOrActivityIndicatorSize = (_effectiveConfiguration.imageSize ?? imageView.sizeThatFits(imageOrActivityIndicatorLimitSize)).limit(to: imageOrActivityIndicatorLimitSize)
                }
            }
            if shouldDisplayTitle {
                let titleLimitSize = CGSize(width: contentLimitSize.width - imageOrActivityIndicatorSize.width - imagePadding, height: contentLimitSize.height).eraseNegative()
                titleSize = titleLabel.sizeThatFits(titleLimitSize)
                titleSize.height = min(titleSize.height, titleLimitSize.height)
            }
            if shouldDisplaySubtitle {
                let subtitleLimitSize = CGSize(width: contentLimitSize.width - imageOrActivityIndicatorSize.width - imagePadding, height: contentLimitSize.height).eraseNegative()
                subtitleSize = subtitleLabel.sizeThatFits(subtitleLimitSize)
                subtitleSize.height = min(subtitleSize.height, subtitleLimitSize.height)
            }
            resultSize.width = horizontalInset + imageOrActivityIndicatorSize.width + imagePadding + max(titleSize.width, subtitleSize.width)
            resultSize.height = verticalInset + max(imageOrActivityIndicatorSize.height, titleSize.height + titlePadding + subtitleSize.height)
        }
        
        if limitSize == CGSize.max {
            bestSize = resultSize
        }
        
        return resultSize
    }
    
    
    // MARK: - Override
    
    open override func removeTarget(_ target: Any?, action: Selector?, for controlEvents: UIControl.Event) {
        super.removeTarget(target, action: action, for: controlEvents)
        
        // Prevent internal target-action from being removed
        let sel = #selector(touchUpInsideTriggered)
        if let actions = actions(forTarget: self, forControlEvent: .touchUpInside) {
            if !actions.contains(NSStringFromSelector(sel)) {
                addTarget(self, action: sel, for: .touchUpInside)
            }
        } else {
            addTarget(self, action: sel, for: .touchUpInside)
        }
    }
    
    open override var isEnabled: Bool {
        didSet {
            if configurationTransformer?.respondsToEnabledChanged == true && isEnabled != oldValue {
                updateConfiguration()
            }
            
            if isEnabled {
                accessibilityTraits.remove(.notEnabled)
            } else {
                accessibilityTraits.insert(.notEnabled)
            }
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            if isSelected != oldValue {
                updateConfiguration()
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
                
        layoutBackground()
        layoutForeground()
    }
    
    open override var contentVerticalAlignment: UIControl.ContentVerticalAlignment {
        didSet {
            if contentVerticalAlignment != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    open override var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        didSet {
            if contentHorizontalAlignment != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // When UIButton and tap gestures coexist, the button's touch event will respond first, but UIControl will not. Add this code to simulate the behavior of UIButton.
        // See also: https://stackoverflow.com/questions/32440418/why-is-a-uibutton-consuming-touches-but-not-a-uicontrol
        if let tapGestureRecognizer = gestureRecognizer as? UITapGestureRecognizer {
            if tapGestureRecognizer.numberOfTapsRequired == 1 && tapGestureRecognizer.numberOfTouchesRequired == 1 {
                return false
            }
        }
        return true
    }
}
