//
//  RichText.Style.Action.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/18.
//

import UIKit

public extension RichText.Style {
    
    struct Action {
        public enum Trigger: Hashable {
            case tap, longPress
        }
        
        public struct Highlight {
            let attributes: [NSAttributedString.Key : Any]
        }
        
        public struct Target {
            public enum Content {
                case string(NSAttributedString)
                case attachment(NSTextAttachment)
            }
            
            public let content: Content
            public let range: NSRange
        }
        
        let trigger: Trigger
        let highlights: [Highlight]
        let handler: (Target) -> Void
        
        internal var isExternal: Bool = true
        internal var internalHandler: (() -> Void)?
        
        public init(_ trigger: Trigger = .tap, highlights: [Highlight] = .defalut, handler: @escaping (Target) -> Void) {
            self.trigger = trigger
            self.highlights = highlights
            self.handler = handler
        }
    }
}

public extension RichText.Style.Action.Highlight {
    
    static func foreground(_ value: UIColor) -> Self {
        .init(attributes: [.foregroundColor: value])
    }
    
    static func background(_ value: UIColor) -> Self {
        .init(attributes: [.backgroundColor: value])
    }
    
    static func strikethrough(_ style: NSUnderlineStyle, color: UIColor? = nil) -> Self {
        var attributes = [NSAttributedString.Key : Any]()
        attributes[.strikethroughColor] = color
        attributes[.strikethroughStyle] = style.rawValue
        return .init(attributes: attributes)
    }
    
    static func underline(_ style: NSUnderlineStyle, color: UIColor? = nil) -> Self {
        var attributes = [NSAttributedString.Key : Any]()
        attributes[.underlineColor] = color
        attributes[.underlineStyle] = style.rawValue
        return .init(attributes: attributes)
    }
    
    static func shadow(_ value: NSShadow) -> Self {
        .init(attributes: [.shadow: value])
    }
    
    static func stroke(_ width: CGFloat = 0, color: UIColor? = nil) -> Self {
        var attributes = [NSAttributedString.Key : Any]()
        attributes[.strokeColor] = color
        attributes[.strokeWidth] = width
        return .init(attributes: attributes)
    }
}

public extension Array where Element == RichText.Style.Action.Highlight {
    
    static let defalut: [RichText.Style.Action.Highlight] = [.underline(.single)]
    static let empty: [RichText.Style.Action.Highlight] = []
}

extension Array where Element == RichText.Style {
    
    /// Merge Actions When multiple actions exist, merge all actions into one array
    func mergingActions() -> Array<Element> {
        var styles = self
        
        var actions = styles.compactMap {
            $0.attributes[.action] as? RichText.Style.Action
        }
        actions.append(contentsOf: styles.compactMap {
            $0.attributes[.action] as? [RichText.Style.Action]
        }.flatMap({ $0 }))
        
        if !actions.isEmpty {
            styles.removeAll(where: {
                $0.attributes.keys.contains(.action)
            })
            styles.append(.init(attributes: [.action: actions]))
        }
        return styles
    }
}

extension RichText.Style.Action.Trigger {
    
    func matching(_ gesture: UIGestureRecognizer) -> Bool {
        switch self {
        case .tap where gesture is UITapGestureRecognizer:
            return true
        case .longPress where gesture is UILongPressGestureRecognizer:
            return true
        default:
            return false
        }
    }
}

extension NSAttributedString.Key {
    
    static let action = NSAttributedString.Key("LLPUI.RichText.AttributedStringKey.Action")
}

extension NSAttributedString {
    
    func get(_ range: NSRange) -> RichText.Style.Action.Target {
        let substring = attributedSubstring(from: range)
        if let attachment = substring.attribute(.attachment, at: 0, effectiveRange: nil) as? NSTextAttachment {
            return .init(content: .attachment(attachment), range: range)
        } else {
            return .init(content: .string(substring), range: range)
        }
    }
}
