//
//  RichText+Interpolation.swift
//  XUI
//
//  Created by xueqooy on 2023/8/18.
//

import Foundation
import UIKit

extension RichText: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        attributedString = .init(string: value)
    }
}

extension RichText: ExpressibleByStringInterpolation {
    public init(stringInterpolation: RichTextInterpolation) {
        attributedString = .init(attributedString: stringInterpolation.attributedString)
    }
}

public struct RichTextInterpolation: StringInterpolationProtocol {
    public typealias Style = RichText.Style
    public typealias StyleStrategy = RichText.StyleStrategy
    public typealias Attachment = RichText.Attachment

    let attributedString: NSMutableAttributedString

    public init(literalCapacity _: Int, interpolationCount _: Int) {
        attributedString = .init()
    }

    public mutating func appendLiteral(_ literal: String) {
        attributedString.append(.init(string: literal))
    }

    public mutating func appendInterpolation(_ value: NSAttributedString) {
        attributedString.append(value)
    }

    public mutating func appendInterpolation(_ value: RichText) {
        attributedString.append(value.attributedString)
    }

    public mutating func appendInterpolation<T>(_ value: T, attributes: [NSAttributedString.Key: Any]) {
        attributedString.append(.init(string: "\(value)", attributes: attributes))
    }

    public mutating func appendInterpolation<T>(_ value: T) {
        attributedString.append(.init(string: "\(value)"))
    }

    public mutating func appendInterpolation<T>(_ value: T, _ styles: Style...) {
        attributedString.append(RichText("\(value)", styles: styles).attributedString)
    }

    public mutating func appendInterpolation<T>(_ value: T, _ styles: [Style]) {
        attributedString.append(RichText("\(value)", styles: styles).attributedString)
    }

    public mutating func appendInterpolation(_ value: NSAttributedString, _ styles: Style...) {
        attributedString.append(RichText(value, styles: styles).attributedString)
    }

    public mutating func appendInterpolation(_ value: NSAttributedString, _ styles: [Style]) {
        attributedString.append(RichText(value, styles: styles).attributedString)
    }

    public mutating func appendInterpolation(_ value: Attachment, _ styles: Style...) {
        attributedString.append(RichText(.init(attachment: value.asTextAttachment()), styles: styles).attributedString)
    }

    public mutating func appendInterpolation(_ value: NSTextAttachment, _ styles: Style...) {
        attributedString.append(RichText(.init(attachment: value), styles: styles).attributedString)
    }

    public mutating func appendInterpolation(_ value: RichText, _ styles: Style...) {
        attributedString.append(RichText(value, styles: styles).attributedString)
    }

    public mutating func appendInterpolation(_ value: RichText, _ styles: [Style]) {
        attributedString.append(RichText(value, styles: styles).attributedString)
    }

    public mutating func appendInterpolation(supplement value: RichText, _ styles: Style...) {
        attributedString.append(RichText(value, styleStrategy: .supplement, styles: styles).attributedString)
    }

    public mutating func appendInterpolation(supplement value: RichText, _ styles: [Style]) {
        attributedString.append(RichText(value, styleStrategy: .supplement, styles: styles).attributedString)
    }

    public mutating func appendInterpolation(override value: RichText, _ styles: Style...) {
        attributedString.append(RichText(value, styleStrategy: .override, styles: styles).attributedString)
    }

    public mutating func appendInterpolation(override value: RichText, _ styles: [Style]) {
        attributedString.append(RichText(value, styleStrategy: .override, styles: styles).attributedString)
    }
}
