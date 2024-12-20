//
//  LinkedLabel.swift
//  XUI
//
//  Created by xueqooy on 2023/2/22.
//

import Combine
import UIKit
import XKit

/// a label with link behavior.
open class LinkedLabel: InsetLabel {
    private enum Constants {
        static let highlightedAlpha: CGFloat = 0.35
    }

    public var linkFont: UIFont = Fonts.button2 {
        didSet {
            links.forEach { addAttributes(for: $0, isHighlighted: false) }
        }
    }

    public typealias LinkAndTag = (String, String?)

    public var linkDidTap: ((LinkAndTag) -> Void)?
    public var didTap: ((LinkAndTag?) -> Void)?

    public var linkDidTapPublisher: AnyPublisher<LinkAndTag, Never> {
        linkDidTapSubject.eraseToAnyPublisher()
    }

    private var linkDidTapSubject = PassthroughSubject<LinkAndTag, Never>()

    /// A link or outside of links have been tapped
    public var didTapPublisher: AnyPublisher<LinkAndTag?, Never> {
        didTapSubject.eraseToAnyPublisher()
    }

    private var didTapSubject = PassthroughSubject<LinkAndTag?, Never>()

    private var cancellables = Set<AnyCancellable>()

    private var links: [String] = []

    private var tagForLink = [String: String]()

    private var selectedLink: String?

    override public init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    private func initialize() {
        isUserInteractionEnabled = true
        textColor = Colors.bodyText1
        font = Fonts.body2
        numberOfLines = 0
    }

    public func set(text: String, links: [String]) {
        self.links = links
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        // Append a whitespace to fix wrong endRect.
        let attributedText = NSMutableAttributedString(string: text + " ", attributes: [.font: font!, .foregroundColor: textColor!, .paragraphStyle: paragraphStyle])
        self.attributedText = attributedText

        links.forEach { addAttributes(for: $0, isHighlighted: false) }
    }

    /// Identify links based on tags, different tags cannot be marked with the same link.
    ///
    ///  Example:
    ///  ```
    ///  set(text: "##Terms of Service## and **Privacy Policy**.", linkTags: ["##", "**"], actionForTag: {_ in })
    ///  ```
    ///
    /// - warning:
    ///  NOT ALLOW !!!
    ///  ```
    ///  set(text: "I will not ##desert## my dessert in the **desert**.", linkTags: ["##", "**"], actionForTag: {_ in })
    ///  ```
    ///
    public func set(text: String, linkTags: [String]) {
        tagForLink.removeAll()

        var cleanText = text
        var links = [String]()

        for tag in linkTags {
            while true {
                guard let startRange = cleanText.range(of: tag) else {
                    break
                }

                cleanText.removeSubrange(startRange)

                guard let endRange = cleanText.range(of: tag) else {
                    break
                }

                cleanText.removeSubrange(endRange)

                let link = String(cleanText[startRange.lowerBound ..< endRange.lowerBound])
                if let existingTag = tagForLink[link], existingTag != tag {
                    Asserts.failure("Cannot mark the same link with different tags", tag: "XUI")
                }
                tagForLink[link] = tag
                links.append(link)
            }
        }

        set(text: cleanText, links: links)
    }

    private func addAttributes(for link: String, isHighlighted: Bool) {
        let attributedText = self.attributedText!.mutableCopy() as! NSMutableAttributedString
        let range = (attributedText.string as NSString).range(of: link)

        var attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: linkFont,
        ]
        attributes[.foregroundColor] = Colors.teal.withAlphaComponent(isHighlighted ? Constants.highlightedAlpha : 1.0)

        attributedText.addAttributes(attributes, range: range)
        self.attributedText = attributedText
    }

    private func detectLink(_ point: CGPoint) -> String? {
        let container = NSTextContainer(size: CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        container.lineFragmentPadding = 0
        let manager = NSLayoutManager()
        manager.addTextContainer(container)
        let store = NSTextStorage(attributedString: attributedText!)
        store.addLayoutManager(manager)

        for link in links {
            var range = (attributedText!.string as NSString).range(of: link)
            manager.characterRange(forGlyphRange: range, actualGlyphRange: &range)

            var beginRect = manager.lineFragmentRect(forGlyphAt: range.location, effectiveRange: nil)
            var endRect = manager.lineFragmentRect(forGlyphAt: range.location + range.length, effectiveRange: nil)
            let beginPoint = manager.location(forGlyphAt: range.location)
            let endPoint = manager.location(forGlyphAt: range.location + range.length)

            if beginRect.origin.y == endRect.origin.y {
                beginRect.origin.x = beginPoint.x
                beginRect.size.width = abs(endPoint.x - beginPoint.x)
                if beginRect.contains(point) { return link }
            } else {
                let rect = CGRect(x: 0, y: beginRect.maxY, width: beginRect.width, height: endRect.minY - beginRect.maxY)
                if rect.contains(point) { return link }

                beginRect.origin.x = beginPoint.x
                beginRect.size.width -= beginPoint.x
                if beginRect.contains(point) { return link }

                endRect.size.width = endPoint.x
                if endRect.contains(point) { return link }
            }
        }
        return nil
    }

    private func cancelSelection() {
        guard let link = selectedLink else { return }
        addAttributes(for: link, isHighlighted: false)
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        selectedLink = detectLink(point)
        if let link = selectedLink {
            addAttributes(for: link, isHighlighted: true)
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        if let selectedLink = selectedLink,
           let point = touches.first?.location(in: self),
           let link = detectLink(point), selectedLink == link
        {
            let tag = tagForLink[link]
            linkDidTap?((link, tag))
            didTap?((link, tag))
            linkDidTapSubject.send((link, tag))
            didTapSubject.send((link, tag))
        } else {
            didTap?(nil)
            didTapSubject.send(nil)
        }

        cancelSelection()
    }

    override public func touchesCancelled(_: Set<UITouch>, with _: UIEvent?) {
        cancelSelection()
    }
}
