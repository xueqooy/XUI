//
//  RichText.Style.swift
//  XUI
//
//  Created by xueqooy on 2023/8/17.
//

import Foundation

public extension RichText {
    
    struct Style {
        let attributes: [NSAttributedString.Key : Any]
    }
}

public extension RichText.Style {
    
    enum WritingDirection {
        case LRE
        case RLE
        case LRO
        case RLO
        
        fileprivate var value: [Int] {
            switch self {
            case .LRE:  return [NSWritingDirection.leftToRight.rawValue | NSWritingDirectionFormatType.embedding.rawValue]
                
            case .RLE:  return [NSWritingDirection.rightToLeft.rawValue | NSWritingDirectionFormatType.embedding.rawValue]
                
            case .LRO:  return [NSWritingDirection.leftToRight.rawValue | NSWritingDirectionFormatType.override.rawValue]
                
            case .RLO:  return [NSWritingDirection.rightToLeft.rawValue | NSWritingDirectionFormatType.override.rawValue]
            }
        }
    }
}

public extension RichText.Style {
    
    static func attributes(_ value: [NSAttributedString.Key: Any]) -> Self {
        .init(attributes: value)
    }
    
    static func font(_ value: UIFont) -> Self {
        .init(attributes: [.font: value])
    }
    
    static func foreground(_ value: UIColor) -> Self {
        .init(attributes: [.foregroundColor: value])
    }
    
    static func background(_ value: UIColor) -> Self {
        .init(attributes: [.backgroundColor: value])
    }
    
    static func ligature(_ value: Bool) -> Self {
        .init(attributes: [.ligature: value ? 1 : 0])
    }
    
    static func kern(_ value: CGFloat) -> Self {
        .init(attributes: [.kern: value])
    }
    
    static func strikethrough(_ style: NSUnderlineStyle, color: UIColor? = nil) -> Self {
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.strikethroughColor] = color
        attributes[.strikethroughStyle] = style.rawValue
        return .init(attributes: attributes)
    }
    
    static func underline(_ style: NSUnderlineStyle, color: UIColor? = nil) -> Self {
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.underlineColor] = color
        attributes[.underlineStyle] = style.rawValue
        return .init(attributes: attributes)
    }
    
    static func link(_ value: String) -> Self {
        guard let url = URL(string: value) else { return .init(attributes: [:])}
        
        return link(url)
    }
    static func link(_ value: URL) -> Self {
        .init(attributes: [.link: value])
    }
    
    static func baselineOffset(_ value: CGFloat) -> Self {
        .init(attributes: [.baselineOffset: value])
    }
    
    static func shadow(_ value: NSShadow) -> Self {
        .init(attributes: [.shadow: value])
    }
    
    static func stroke(_ width: CGFloat = 0, color: UIColor? = nil) -> Self {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.strokeColor] = color
        attributes[.strokeWidth] = width
        return .init(attributes: attributes)
    }
    
    static func textEffect(_ value: String) -> Self {
        .init(attributes: [.textEffect: value])
    }
    static func textEffect(_ value: NSAttributedString.TextEffectStyle) -> Self {
        textEffect(value.rawValue)
    }
    
    static func obliqueness(_ value: CGFloat = 0.1) -> Self {
        return .init(attributes: [.obliqueness: value])
    }
    
    static func expansion(_ value: CGFloat = 0.0) -> Self {
        return .init(attributes: [.expansion: value])
    }
    
    static func writingDirection(_ value: [Int]) -> Self {
        .init(attributes: [.writingDirection: value])
    }
    static func writingDirection(_ value: WritingDirection) -> Self {
        writingDirection(value.value)
    }
    
    static func verticalGlyphForm(_ value: Bool) -> Self {
        .init(attributes: [.verticalGlyphForm: value ? 1 : 0])
    }
    
    
    // Paragraph
    
    static func paragraph(_ value: Paragraph...) -> Self {
        let paragrapStyle = value
            .reduce(Paragraph(values: [:]), { $0.merging($1) })
            .asParagraphStyle()
        return .init(attributes: value.isEmpty ? [:] : [.paragraphStyle : paragrapStyle])
    }
    
    static func paragraph(_ value: [Paragraph]) -> Self {
        let paragrapStyle = value
            .reduce(Paragraph(values: [:]), { $0.merging($1) })
            .asParagraphStyle()
        return .init(attributes: value.isEmpty ? [:] : [.paragraphStyle : paragrapStyle])
    }
    
    
    // Action
    
    static func action(_ handler: @escaping (Action.Target) -> Void) -> Self {
        .init(attributes: [.action : Action(handler: handler)])
    }
    
    static func action(_ handler: @escaping () -> Void) -> Self {
        .init(attributes: [.action : Action(handler: { _ in handler() })])
    }
    
    static func action(_ highlights: [Action.Highlight], _ handler: @escaping (Action.Target) -> Void) -> Self {
        .init(attributes: [.action : Action(highlights: highlights, handler: handler)])
    }
    
    static func action(_ highlights: [Action.Highlight], _ handler: @escaping () -> Void) -> Self {
        .init(attributes: [.action : Action(highlights: highlights, handler: { _ in handler() })])
    }
    
    static func action(_ trigger: Action.Trigger, _ handler: @escaping (Action.Target) -> Void) -> Self {
        .init(attributes: [.action : Action(trigger, handler: handler)])
    }
    
    static func action(_ trigger: Action.Trigger, _ handler: @escaping () -> Void) -> Self {
        .init(attributes: [.action : Action(trigger, handler: { _ in handler() })])
    }
    
    static func action(_ trigger: Action.Trigger, _ highlights: [Action.Highlight], _ handler: @escaping (Action.Target) -> Void) -> Self {
        .init(attributes: [.action: Action(trigger, highlights: highlights, handler: handler)])
    }
    
    static func action(_ trigger: Action.Trigger, _ highlights: [Action.Highlight], _ handler: @escaping () -> Void) -> Self {
        .init(attributes: [.action: Action(trigger, highlights: highlights, handler: { _ in handler() })])
    }
    
    static func action(_ value: Action) -> Self {
        return .init(attributes: [.action: value])
    }
}
