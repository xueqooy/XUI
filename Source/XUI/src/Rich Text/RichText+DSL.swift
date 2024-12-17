//
//  RichText+DSL.swift
//  XUI
//
//  Created by xueqooy on 2023/11/22.
//

import Foundation
import XKit

public protocol RichTextConvertible {
    func asRichText() -> RichText
}

extension String: RichTextConvertible {
    public func asRichText() -> RichText {
        RichText(self)
    }
}

extension NSAttributedString: RichTextConvertible {
    public func asRichText() -> RichText {
        RichText(self)
    }
}

extension RichText: RichTextConvertible {
    public func asRichText() -> RichText {
        self
    }
}

public extension RichText {
    init(@ArrayBuilder<RichTextConvertible> content: () -> [RichTextConvertible]) {
        let richText = content().reduce(into: "" as RichText) {
            $0 += $1.asRichText()
        }
        
        self.init(richText)
    }
}

public func RTSupplement(_ styles: RichText.Style..., @ArrayBuilder<RichTextConvertible> content: () -> [RichTextConvertible]) -> RichText {
    let richText = content().reduce(into: "" as RichText) {
        $0 += $1.asRichText()
    }
    
    return RichText(richText, styleStrategy: .supplement, styles: styles)
}

public func RTSupplement(_ styles: [RichText.Style] = [], @ArrayBuilder<RichTextConvertible> content: () -> [RichTextConvertible]) -> RichText {
    let richText = content().reduce(into: "" as RichText) {
        $0 += $1.asRichText()
    }
    
    return RichText(richText, styleStrategy: .supplement, styles: styles)
}

public func RTOverride(_ styles: RichText.Style..., @ArrayBuilder<RichTextConvertible> content: () -> [RichTextConvertible]) -> RichText {
    let richText = content().reduce(into:  "" as RichText) {
        $0 += $1.asRichText()
    }
    
    return RichText(richText, styleStrategy: .override, styles: styles)
}

public func RTOverride(_ styles: [RichText.Style] = [], @ArrayBuilder<RichTextConvertible> content: () -> [RichTextConvertible]) -> RichText {
    let richText = content().reduce(into:  "" as RichText) {
        $0 += $1.asRichText()
    }
    
    return RichText(richText, styleStrategy: .override, styles: styles)
}

public func RTText(_ value: RichTextConvertible, _ styles: RichText.Style...) -> RichText {
    .init(value.asRichText(), styles: styles)
}

public func RTText(_ value: RichTextConvertible, _ styles: [RichText.Style] = []) -> RichText {
    .init(value.asRichText(), styles: styles)
}

public func RTLineBreak(_ count: Int, _ styles: RichText.Style...) -> RichText {
    .init(String(repeating: "\n", count: count), styles: styles)
}

public func RTLineBreak(_ count: Int, _ styles: [RichText.Style] = []) -> RichText {
    .init(String(repeating: "\n", count: count), styles: styles)
}

public func RTLineBreak(_ styles: RichText.Style...) -> RichText {
    .init(String(repeating: "\n", count: 1), styles: styles)
}

public func RTLineBreak(_ styles: [RichText.Style] = []) -> RichText {
    .init(String(repeating: "\n", count: 1), styles: styles)
}

public func RTSpace(_ count: Int, _ styles: RichText.Style...) -> RichText {
    .init(String(repeating: " ", count: count), styles: styles)
}

public func RTSpace(_ count: Int, _ styles: [RichText.Style] = []) -> RichText {
    .init(String(repeating: " ", count: count), styles: styles)
}

public func RTSpace(_ styles: RichText.Style...) -> RichText {
    .init(String(repeating: " ", count: 1), styles: styles)
}

public func RTSpace(_ styles: [RichText.Style] = []) -> RichText {
    .init(String(repeating: " ", count: 1), styles: styles)
}

public func RTAttachment(_ attachment: RichText.Attachment, _ styles: RichText.Style...) -> RichText {
    .init(attachment, styles: styles)
}

public func RTAttachment(_ attachment: RichText.Attachment, _ styles: [RichText.Style] = []) -> RichText {
    .init(attachment, styles: styles)
}

