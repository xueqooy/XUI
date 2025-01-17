//
//  DesignedButtonConfigurationTransformer.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/9/19.
//

import UIKit

public class DesignedButtonConfigurationTransformer: PlainButtonConfigurationTransformer {
    enum Constants {
        static let largeFont = Fonts.button1
        static let mediumFont = Fonts.button2
        static let smallFont = Fonts.button3
        static let largeImagePadding: CGFloat = 16
        static let mediumImagePadding: CGFloat = 10
        static let smallImagePadding: CGFloat = 4
        static let normalContentInsets: Insets = .directional(top: 12, leading: 32, bottom: 12, trailing: 32)
        static let smallContentInsets: Insets = .directional(top: 4, leading: 32, bottom: 4, trailing: 32)
    }

    public enum Style: CaseIterable {
        case primary
        case secondary
        case borderless
        case borderlessSmall
    }

    public enum ContentInsetsMode {
        case `default`

        case ignoreHorizontal
        case ignoreVertical

        case overrideHorizontal(CGFloat)
        case overrideVertical(CGFloat)

        case override(Insets)
    }

    static let primaryConfiguration: ButtonConfiguration = {
        var bg = BackgroundConfiguration.clear()
        bg.cornerStyle = .capsule

        var conf = ButtonConfiguration()
        conf.titleFont = Constants.largeFont
        conf.imagePadding = Constants.largeImagePadding
        conf.contentInsets = Constants.normalContentInsets
        conf.indicatorSize = CGSize.square(Constants.largeFont.lineHeight)
        conf.background = bg

        return conf
    }()

    static let primarySmallConfiguration: ButtonConfiguration = {
        var bg = BackgroundConfiguration.clear()
        bg.cornerStyle = .fixed(8)

        var conf = ButtonConfiguration()
        conf.titleFont = Constants.smallFont
        conf.imagePadding = Constants.mediumImagePadding
        conf.contentInsets = Constants.smallContentInsets
        conf.indicatorSize = CGSize.square(Constants.smallFont.lineHeight)
        conf.background = bg

        return conf
    }()

    static let secondaryConfiguration: ButtonConfiguration = {
        var bg = BackgroundConfiguration.clear()
        bg.stroke.width = 1
        bg.cornerStyle = .capsule

        var conf = ButtonConfiguration()
        conf.titleFont = Constants.largeFont
        conf.imagePadding = Constants.largeImagePadding
        conf.contentInsets = Constants.normalContentInsets
        conf.indicatorSize = CGSize.square(Constants.largeFont.lineHeight)
        conf.background = bg

        return conf
    }()

    static let secondarySmallConfiguration: ButtonConfiguration = {
        var bg = BackgroundConfiguration.clear()
        bg.stroke.width = 1
        bg.cornerStyle = .fixed(8)

        var conf = ButtonConfiguration()
        conf.titleFont = Constants.smallFont
        conf.imagePadding = Constants.mediumImagePadding
        conf.contentInsets = Constants.smallContentInsets
        conf.indicatorSize = CGSize.square(Constants.smallFont.lineHeight)
        conf.background = bg

        return conf
    }()

    static let borderlessConfiguration: ButtonConfiguration = {
        var bg = BackgroundConfiguration.clear()

        var conf = ButtonConfiguration()
        conf.titleFont = Constants.mediumFont
        conf.imagePadding = Constants.smallImagePadding
        conf.indicatorSize = CGSize.square(Constants.mediumFont.lineHeight)
        conf.background = bg

        return conf
    }()

    static let borderlessSmallConfiguration: ButtonConfiguration = {
        var bg = BackgroundConfiguration.clear()

        var conf = ButtonConfiguration()
        conf.titleFont = Constants.smallFont
        conf.imagePadding = Constants.smallImagePadding
        conf.indicatorSize = CGSize.square(Constants.smallFont.lineHeight)
        conf.background = bg

        return conf
    }()

    public var style: Style

    public var mainColor: UIColor {
        didSet {
            isDarkMainColor = mainColor.isDark
        }
    }

    public var alternativeBackgroundColor: UIColor

    public var contentInsetsMode: ContentInsetsMode

    private var isDarkMainColor: Bool = false

    public init(style: Style, mainColor: UIColor = Colors.teal, alternativeBackgroundColor: UIColor = .clear, contentInsetsMode: ContentInsetsMode = .default) {
        self.style = style
        self.mainColor = mainColor
        self.alternativeBackgroundColor = alternativeBackgroundColor
        self.contentInsetsMode = contentInsetsMode

        isDarkMainColor = mainColor.isDark
    }

    override public func update(_ configuration: inout ButtonConfiguration, for button: Button) {
        // Apply template
        let template: ButtonConfiguration

        switch style {
        case .primary:
            template = Self.primaryConfiguration
        case .secondary:
            template = Self.secondaryConfiguration
        case .borderless:
            template = Self.borderlessConfiguration
        case .borderlessSmall:
            template = Self.borderlessSmallConfiguration
        }

        configuration.titleFont = template.titleFont
        configuration.imagePadding = template.imagePadding
        configuration.indicatorSize = template.indicatorSize
        configuration.background?.stroke.width = template.background?.stroke.width ?? 0
        configuration.background?.cornerStyle = template.background?.cornerStyle

        // Apply content Inset
        var contentInsets = template.contentInsets
        switch contentInsetsMode {
        case .ignoreHorizontal:
            contentInsets = .nondirectional(top: contentInsets.top, left: 0, bottom: contentInsets.bottom, right: 0)

        case .ignoreVertical:
            switch contentInsets {
            case let .directional(_, leading, _, trailing):
                contentInsets = .directional(top: 0, leading: leading, bottom: 0, trailing: trailing)

            case let .nondirectional(_, left, _, right):
                contentInsets = .nondirectional(top: 0, left: left, bottom: 0, right: right)
            }

        case let .overrideHorizontal(inset):
            contentInsets = .nondirectional(top: contentInsets.top, left: inset, bottom: contentInsets.bottom, right: inset)

        case let .overrideVertical(inset):
            switch contentInsets {
            case let .directional(_, leading, _, trailing):
                contentInsets = .directional(top: inset, leading: leading, bottom: inset, trailing: trailing)

            case let .nondirectional(_, left, _, right):
                contentInsets = .nondirectional(top: inset, left: left, bottom: inset, right: right)
            }

        case let .override(inests):
            contentInsets = inests

        default:
            break
        }

        configuration.contentInsets = contentInsets

        // Apply colors
        let foregroundColor: UIColor
        let backgroundColor: UIColor
        let strokeColor: UIColor

        switch style {
        case .primary /* , primary */:
            foregroundColor = isDarkMainColor ? .white : .black
            backgroundColor = mainColor
            strokeColor = .clear

        case .secondary /* , .secondarySmall */:
            foregroundColor = mainColor
            backgroundColor = alternativeBackgroundColor
            strokeColor = mainColor

        case .borderless, .borderlessSmall:
            foregroundColor = mainColor
            backgroundColor = alternativeBackgroundColor
            strokeColor = .clear
        }

        configuration.foregroundColor = foregroundColor
        configuration.background?.fillColor = backgroundColor
        configuration.background?.stroke.color = strokeColor

        super.update(&configuration, for: button)
    }

    override public var shouldAutomaticallyAdjustForegroundAlpha: Bool {
        switch style {
        case .primary /* , primary */:
            return false
        default:
            return true
        }
    }
}

extension DesignedButtonConfigurationTransformer.Style: CustomStringConvertible {
    public var description: String {
        switch self {
        case .primary:
            return "Primary"
        case .secondary:
            return "Secondary"
        case .borderless:
            return "Borderless"
        case .borderlessSmall:
            return "Borderless small"
        }
    }
}
