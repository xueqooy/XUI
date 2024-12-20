//
//  String+Extensions.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/9/21.
//

import UIKit
import XKit

public extension String {
    func preferredSize(for font: UIFont, width: CGFloat = .greatestFiniteMagnitude, numberOfLines: Int = 0) -> CGSize {
        // swiftformat:disable all
        if numberOfLines == 1 {
            return CGSize(
                width: min(self.size(withAttributes: [.font: font]).width, width).flatInPixel(),
                height: font.deviceLineHeightWithLeading
            )
        }
        let maxHeight = numberOfLines > 1 ? font.deviceLineHeightWithLeading * CGFloat(numberOfLines) : .greatestFiniteMagnitude
        let rect = self.boundingRect(
            with: CGSize(width: width, height: maxHeight),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        // swiftformat:enable all
        return CGSize(
            width: rect.width.flatInPixel(),
            height: rect.height.flatInPixel()
        )
    }

    /**
     Cropping out the substring of the specified range in the string will avoid breaking up "character sequences" such as emoji (one emoji emoji occupies 1-4 characters in length).

     For example, for strings“ 😊😞”， Its length is 4. In lessValue mode, trimming (0, 1) yields an empty string, while trimming (0, 2) yields an empty string“ 😊”。
     In non lessValue mode, cropping (0, 1) or (0, 2) yields both“ 😊”。

     - parameter range: Text position to be cropped
     - parameter lessValue: If encountering 'character sequences' during cropping, whether to round down or up
     */
    func substringAvoidBreakingUpCharacterSequences(with range: NSRange, lessValue: Bool) -> String {
        let length = utf16.count
        Asserts.failure("range \(range) out of bounds for string: \(self)", condition: NSMaxRange(range) <= length, tag: "XUI")

        if NSMaxRange(range) > length {
            return ""
        }

        let characterSequencesRange = lessValue ? downRoundRangeOfComposedCharaterSequences(for: range) : (self as NSString).rangeOfComposedCharacterSequences(for: range)

        return (self as NSString).substring(with: characterSequencesRange)
    }

    /// System rangeOfComposedCharacterSequence is up round
    func downRoundRangeOfComposedCharaterSequences(for range: NSRange) -> NSRange {
        if range.length == 0 {
            return range
        }

        let systemRange = (self as NSString).rangeOfComposedCharacterSequences(for: range)
        if range == systemRange {
            return range
        }

        var result = systemRange
        if range.location > systemRange.location {
            // It means that the starting point of the range passed in happens to be in the middle of a character sequence, so this character sequence needs to be discarded, starting from the characters after it
            let beginRange = (self as NSString).rangeOfComposedCharacterSequence(at: range.location)
            result.location = NSMaxRange(beginRange)
            result.length -= beginRange.length
        }
        if NSMaxRange(range) < NSMaxRange(systemRange) {
            // It means that the range endpoint passed in happens to be in the middle of a character sequence, so we need to discard this character sequence and only retrieve the characters before it

            let endRange = (self as NSString).rangeOfComposedCharacterSequence(at: NSMaxRange(range) - 1)

            // If the range passed in as a parameter happens to fall in the middle of an emoji, it will cause the beginRange to be subtracted before and the endRange to be subtracted again, resulting in a negative number (note that the length here is NSUInteger). Therefore, for protection, you can use the 👨‍👩‍👧‍👦  Test, this emoji has a length of 11
            if result.length >= endRange.length {
                result.length = result.length - endRange.length
            } else {
                result.length = 0
            }
        }
        return result
    }
}
