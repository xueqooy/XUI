//
//  RichText+Operator.swift
//  XUI
//
//  Created by xueqooy on 2023/8/18.
//

import Foundation

public extension RichText {
    
    static func += (lhs: inout RichText, rhs: RichText) {
        let string = NSMutableAttributedString(attributedString: lhs.attributedString)
        string.append(rhs.attributedString)
        lhs = .init(string)
    }

    static func + (lhs: RichText, rhs: RichText) -> RichText {
        let string = NSMutableAttributedString(attributedString: lhs.attributedString)
        string.append(rhs.attributedString)
        return .init(string)
    }

    static func += (lhs: inout RichText, rhs: String) {
        lhs += RichText(rhs)
    }
    
    static func += (lhs: inout String, rhs: RichText) {
        lhs += rhs.attributedString.string
    }

    static func + (lhs: RichText, rhs: String) -> RichText {
        return lhs + RichText(rhs)
    }

    static func + (lhs: String, rhs: RichText) -> RichText {
        return RichText(lhs) + rhs
    }
    
    static func += (lhs: inout RichText, rhs: NSAttributedString) {
        lhs += RichText(rhs)
    }
    
    static func += (lhs: inout NSMutableAttributedString, rhs: RichText) {
        lhs.append(rhs.attributedString)
    }
    
    static func + (lhs: RichText, rhs: NSAttributedString) -> RichText {
        return lhs + RichText(rhs)
    }
    
    static func + (lhs: NSAttributedString, rhs: RichText) -> RichText {
        return RichText(lhs) + rhs
    }
    
    static func += (lhs: inout RichText, rhs: RichText.Style) {
        lhs += (rhs, .init(location: 0, length: lhs.length))
    }
    
    static func += (lhs: inout RichText, rhs: [RichText.Style]) {
        lhs += (rhs, .init(location: 0, length: lhs.length))
    }
    
    static func += (lhs: inout RichText, rhs: (RichText.Style, NSRange)) {
        lhs += ([rhs.0], rhs.1)
    }
    
    static func += (lhs: inout RichText, rhs: ([RichText.Style], NSRange)) {
        lhs = lhs + rhs
    }
    
    static func + (lhs: RichText, rhs: RichText.Style) -> RichText {
        return lhs + (rhs, .init(location: 0, length: lhs.length))
    }
    
    static func + (lhs: RichText, rhs: (RichText.Style, NSRange)) -> RichText {
        return lhs + ([rhs.0], rhs.1)
    }
    
    static func + (lhs: RichText, rhs: ([RichText.Style], NSRange)) -> RichText {
        let string = NSMutableAttributedString(attributedString: lhs.attributedString)
        rhs.0.forEach { string.addAttributes($0.attributes, range: rhs.1) }
        return .init(string)
    }
}
