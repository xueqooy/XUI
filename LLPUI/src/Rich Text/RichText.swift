//
//  RichText.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/17.
//

import Foundation

public struct RichText {
    
    public enum StyleStrategy {
        /// The existing style of the wrapped rich text is not affected by the style
        case supplement
        /// The existing style of the wrapped  rich text will be replaced by the style
        case override
    }
    
    public internal(set) var attributedString: NSAttributedString
    
    public var length: Int {
        attributedString.length
    }
    
    
    // String
    
    public init(_ value: String, styles: Style...) {
        self.attributedString = RichText(.init(string: value), styles: styles).attributedString
    }
    
    public init(_ value: String, styles: [Style] = []) {
        self.attributedString = RichText(.init(string: value), styles: styles).attributedString
    }
    
    
    // NSAttributedString
    
    public init(_ value: NSAttributedString) {
        self.attributedString = value
    }
    
    public init(_ value: NSAttributedString, styles: Style...) {
        self.attributedString = RichText(.init(value), styles: styles).attributedString
    }
    
    public init(_ value: NSAttributedString, styles: [Style] = []) {
        self.attributedString = RichText(.init(value), styles: styles).attributedString
    }
    
    
    // Attachment
    
    init(_ attachment: Attachment, styles: Style...) {
        attributedString = RichText(.init(attachment: attachment.asTextAttachment()), styles: styles).attributedString
    }
    
    init(_ attachment: Attachment, styles: [Style] = []) {
        attributedString = RichText(.init(attachment: attachment.asTextAttachment()), styles: styles).attributedString
    }
    
    init(_ textAttachment: NSTextAttachment, styles: Style...) {
        attributedString = RichText(.init(attachment: textAttachment), styles: styles).attributedString
    }
    
    init(_ textAttachment: NSTextAttachment, styles: [Style] = []) {
        attributedString = RichText(.init(attachment: textAttachment), styles: styles).attributedString
    }
    
    
    // RichText
    
    public init(_ value: RichText, styles: Style...) {
        attributedString = RichText(value, styleStrategy: .supplement, styles: styles).attributedString
    }
    
    public init(_ value: RichText, styles: [Style] = []) {
        attributedString = RichText(value, styleStrategy: .supplement, styles: styles).attributedString
    }
    
    
    // Wrap
    
    public init(_ value: RichText, styleStrategy: StyleStrategy, styles: Style...) {
        attributedString = RichText(value, styleStrategy: styleStrategy, styles: styles).attributedString
    }
    
    public init(_ value: RichText, styleStrategy: StyleStrategy, styles: [Style] = []) {
        guard !styles.isEmpty else {
            attributedString = value.attributedString
            return
        }
        
        let styles = styles.mergingActions()
        
        var genericAttributes: [NSAttributedString.Key: Any] = [:]
        styles.forEach {
            genericAttributes.merge($0.attributes, uniquingKeysWith: { $1 })
        }
      
        let attributedString: NSMutableAttributedString
        switch styleStrategy {
        case .supplement:
            attributedString = .init(attributedString: value.attributedString)
            var extraAttributes: [([NSAttributedString.Key: Any], NSRange)] = []
            
            attributedString.enumerateAttributes(in: .init(location: 0, length: attributedString.length), options: .longestEffectiveRangeNotRequired) { (attributs, range, stop) in
                let keys = Set(genericAttributes.keys).subtracting(Set(attributs.keys))
                extraAttributes.append((genericAttributes.filter { keys.contains($0.key) }, range))
            }
            
            extraAttributes.forEach {
                attributedString.addAttributes($0, range: $1)
            }
        case .override:
            attributedString = .init(attributedString: value.attributedString)
            attributedString.addAttributes(genericAttributes, range: .init(location: 0, length: attributedString.length))
        }
        
        self.attributedString = attributedString
    }
}


// MARK: - CustomStringConvertible

extension RichText: CustomStringConvertible {
    public var description: String {
        .init(describing: attributedString)
    }
}


// MARK: - Equatable

extension RichText: Equatable {
    public static func == (lhs: RichText, rhs: RichText) -> Bool {
        guard lhs.length == rhs.length else {
            return false
        }
        guard lhs.attributedString.string == rhs.attributedString.string else {
            return false
        }
        guard lhs.attributedString.get(.init(location: 0, length: lhs.length)) == rhs.attributedString.get(.init(location: 0, length: rhs.length)) else {
            return false
        }
        return true
    }
}

fileprivate extension Dictionary where Key == NSAttributedString.Key, Value == Any {
    static func == (lhs: [NSAttributedString.Key: Any], rhs: [NSAttributedString.Key: Any]) -> Bool {
        lhs.keys == rhs.keys ? NSDictionary(dictionary: lhs).isEqual(to: rhs) : false
    }
}

fileprivate extension Dictionary where Key == NSRange, Value == [NSAttributedString.Key: Any]  {
    static func == (lhs: [NSRange: [NSAttributedString.Key: Any]], rhs: [NSRange: [NSAttributedString.Key: Any]]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        return Swift.zip(lhs, rhs).allSatisfy { (l, r) -> Bool in
            l.0 == r.0 && l.1 == r.1
        }
    }
}
