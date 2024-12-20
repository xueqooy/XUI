//
//  Tooltip.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/9/21.
//

import UIKit

/// A popover with message text
open class Tooltip: Configurable {
    private enum Constants {
        static let messageFont: UIFont = Fonts.body2
        static let textColor: UIColor = Colors.title
        static let backgroundColor: UIColor = Colors.orange
    }

    public struct Configuration {
        public var preferredDirection: Direction
        public var offset: CGPoint
        public var maximumContentWidth: CGFloat

        public init(preferredDirection: Direction = .down, offset: CGPoint = .zero, maximumContentWidth: CGFloat = 500) {
            self.preferredDirection = preferredDirection
            self.offset = offset
            self.maximumContentWidth = maximumContentWidth
        }

        func applyToPopover(_ popover: Popover, dimissMode: Popover.DismissMode) {
            popover.configuration.dismissMode = dimissMode
            popover.configuration.delayHidingOnAnchor = true
            popover.configuration.preferredDirection = preferredDirection
            popover.configuration.offset = offset
            popover.configuration.maximumContentWidth = maximumContentWidth
        }
    }

    public var configuration: Configuration

    private lazy var popover: Popover = {
        var config = Popover.Configuration()
        config.background = .overlay(color: Constants.backgroundColor, cornerStyle: .fixed(.XUI.smallCornerRadius))
        config.contentInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        return Popover(configuration: config)
    }()

    public init(configuration: Tooltip.Configuration = Tooltip.Configuration()) {
        self.configuration = configuration
    }

    @MainActor public func show(_ message: String, in superview: UIView? = nil, from anchorView: UIView, animated: Bool = true) {
        let messageLabel = createMessageLabel()
        messageLabel.text = message

        configuration.applyToPopover(popover, dimissMode: .tapOnSuperview)
        popover.show(messageLabel, in: superview, from: anchorView, animated: animated)
    }

    @MainActor public func show(_ message: String, links: [String], in superview: UIView? = nil, from anchorView: UIView, animated: Bool = true, onLinkTap: @escaping (String) -> Void) {
        let popover = popover

        let messageLabel = createMessageLabel()
        messageLabel.set(text: message, links: links)
        messageLabel.didTap = { [weak popover] linkAndTag in
            popover?.hide(animated: animated)

            if let linkAndTag = linkAndTag {
                onLinkTap(linkAndTag.0)
            }
        }

        configuration.applyToPopover(popover, dimissMode: .tapOnOutsidePopover)
        popover.show(messageLabel, in: superview, from: anchorView, animated: animated)
    }

    @MainActor public func show(_ message: String, linkTags: [String], in superview: UIView? = nil, from anchorView: UIView, animated: Bool = true, onLinkTap: @escaping (String, String) -> Void) {
        let popover = popover

        let messageLabel = createMessageLabel()
        messageLabel.set(text: message, linkTags: linkTags)
        messageLabel.didTap = { [weak popover] linkAndTag in
            popover?.hide(animated: animated)

            if let linkAndTag = linkAndTag, let tag = linkAndTag.1 {
                onLinkTap(linkAndTag.0, tag)
            }
        }

        configuration.applyToPopover(popover, dimissMode: .tapOnOutsidePopover)
        popover.show(messageLabel, in: superview, from: anchorView, animated: animated)
    }

    @MainActor public func hide(animated: Bool = true) {
        popover.hide(animated: animated)
    }

    private func createMessageLabel() -> LinkedLabel {
        let label = LinkedLabel()
        label.textColor = Constants.textColor
        label.font = Constants.messageFont
        label.numberOfLines = 0
        label.textAlignment = .natural
        return label
    }
}
