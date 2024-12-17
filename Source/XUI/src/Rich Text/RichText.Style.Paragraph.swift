//
//  RichText.Style.Paragraph.swift
//  XUI
//
//  Created by xueqooy on 2023/8/18.
//

import Foundation

public extension RichText.Style {
    struct Paragraph {
        let values: [PartialKeyPath<NSMutableParagraphStyle> : Any]
        
        func asParagraphStyle() -> NSParagraphStyle {
            let style = NSMutableParagraphStyle()
            
            func write<Value>(keyPath: ReferenceWritableKeyPath<NSMutableParagraphStyle, Value>, value: Value) {
                style[keyPath: keyPath] = value
            }
            
            for (keyPath, value) in values {
                if let keyPath = keyPath as? ReferenceWritableKeyPath<_, CGFloat> {
                    write(keyPath: keyPath, value: value as! CGFloat)
                } else if let keyPath = keyPath as? ReferenceWritableKeyPath<_, Float> {
                    write(keyPath: keyPath, value: value as! Float)
                } else if let keyPath = keyPath as? ReferenceWritableKeyPath<_, Bool> {
                    write(keyPath: keyPath, value: value as! Bool)
                } else if let keyPath = keyPath as? ReferenceWritableKeyPath<_, NSTextAlignment> {
                    write(keyPath: keyPath, value: value as! NSTextAlignment)
                } else if let keyPath = keyPath as? ReferenceWritableKeyPath<_, NSLineBreakMode> {
                    write(keyPath: keyPath, value: value as! NSLineBreakMode)
                } else if let keyPath = keyPath as? ReferenceWritableKeyPath<_, NSWritingDirection> {
                    write(keyPath: keyPath, value: value as! NSWritingDirection)
                } else if let keyPath = keyPath as? ReferenceWritableKeyPath<_, [NSTextTab]> {
                    write(keyPath: keyPath, value: value as! [NSTextTab])
                } else if let keyPath = keyPath as? ReferenceWritableKeyPath<_, NSParagraphStyle.LineBreakStrategy> {
                    write(keyPath: keyPath, value: value as! NSParagraphStyle.LineBreakStrategy)
                } else {
                    fatalError()
                }
            }
            
            return style
        }
        
        func merging(_ paragraph: Paragraph) -> Paragraph {
            var values = self.values
            values.merge(paragraph.values, uniquingKeysWith: { $1 })
            return .init(values: values)
        }
    }
}

public extension RichText.Style.Paragraph {
    
    static func lineSpacing(_ value: CGFloat) -> Self {
        .init(values: [\.lineSpacing : value])
    }
    
    static func paragraphSpacing(_ value: CGFloat) -> Self {
        .init(values: [\.paragraphSpacing : value])
    }
    
    static func alignment(_ value: NSTextAlignment) -> Self {
        .init(values: [\.alignment : value])
    }
    
    static func firstLineHeadIndent(_ value: CGFloat) -> Self {
        .init(values: [\.firstLineHeadIndent : value])
    }
    
    static func headIndent(_ value: CGFloat) -> Self {
        .init(values: [\.headIndent : value])
    }
    
    static func tailIndent(_ value: CGFloat) -> Self {
        .init(values: [\.tailIndent : value])
    }
    
    static func lineBreakMode(_ value: NSLineBreakMode) -> Self {
        .init(values: [\.lineBreakMode : value])
    }
    
    static func minimumLineHeight(_ value: CGFloat) -> Self {
        .init(values: [\.minimumLineHeight : value])
    }
    
    static func maximumLineHeight(_ value: CGFloat) -> Self {
        .init(values: [\.maximumLineHeight : value])
    }
    
    static func baseWritingDirection(_ value: NSWritingDirection) -> Self {
        .init(values: [\.baseWritingDirection : value])
    }
    
    static func lineHeightMultiple(_ value: CGFloat) -> Self {
        .init(values: [\.lineHeightMultiple : value])
    }
    
    static func paragraphSpacingBefore(_ value: CGFloat) -> Self {
        .init(values: [\.paragraphSpacingBefore : value])
    }
    
    static func hyphenationFactor(_ value: Float) -> Self {
        .init(values: [\.hyphenationFactor : value])
    }
    
    @available(iOS 15.0, *)
    static func usesDefaultHyphenation(_ value: Bool) -> Self {
        .init(values: [\.usesDefaultHyphenation : value])
    }
    
    static func tabStops(_ value: [NSTextTab]) -> Self {
        .init(values: [\.tabStops : value])
    }
    
    static func defaultTabInterval(_ value: CGFloat) -> Self {
        .init(values: [\.defaultTabInterval : value])
    }
    
    static func allowsDefaultTighteningForTruncation(_ value: Bool) -> Self {
        .init(values: [\.allowsDefaultTighteningForTruncation : value])
    }
    
    static func lineBreakStrategy(_ value: NSParagraphStyle.LineBreakStrategy) -> Self {
        .init(values: [\.lineBreakStrategy : value])
    }
}
