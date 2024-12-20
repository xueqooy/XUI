//
//  NSAttributedString+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2023/8/18.
//

import Foundation

extension NSAttributedString {
    func contains(_ name: Key) -> Bool {
        var result = false
        enumerateAttribute(name, in: .init(location: 0, length: length), options: .longestEffectiveRangeNotRequired) { value, _, stop in
            guard value != nil else { return }
            result = true
            stop.pointee = true
        }
        return result
    }

    func get<T>(_ name: Key) -> [NSRange: T] {
        var result: [NSRange: T] = [:]
        enumerateAttribute(name, in: .init(location: 0, length: length), options: .longestEffectiveRangeNotRequired) { value, range, _ in
            guard let value = value as? T else { return }
            result[range] = value
        }
        return result
    }

    func get(_ range: NSRange) -> [NSRange: [NSAttributedString.Key: Any]] {
        var result: [NSRange: [NSAttributedString.Key: Any]] = [:]
        enumerateAttributes(in: range, options: .longestEffectiveRangeNotRequired) { attributes, range, _ in
            result[range] = attributes
        }
        return result
    }

    func reset(range: NSRange, attributes handle: (inout [NSAttributedString.Key: Any]) -> Void) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: self)
        enumerateAttributes(in: range, options: .longestEffectiveRangeNotRequired) { attributes, range, _ in
            var temp = attributes
            handle(&temp)
            string.setAttributes(temp, range: range)
        }
        return string
    }
}
