//
//  RichText.UILabelLayoutManagerDelegate.swift
//  XUI
//
//  Created by xueqooy on 2023/8/18.
//

import UIKit

extension RichText {
    class UILabelLayoutManagerDelegate: NSObject, NSLayoutManagerDelegate {
        private struct Maximum {
            let font: UIFont
            let lineHeight: CGFloat
            let lineSpacing: CGFloat
            let paragraph: NSParagraphStyle?
        }

        let scaledMetrics: UILabel.ScaledMetrics?
        let baselineAdjustment: UIBaselineAdjustment

        init(scaledMetrics: UILabel.ScaledMetrics?, baselineAdjustment: UIBaselineAdjustment) {
            self.scaledMetrics = scaledMetrics
            self.baselineAdjustment = baselineAdjustment
            super.init()
        }

        func layoutManager(_ layoutManager: NSLayoutManager,
                           shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<CGRect>,
                           lineFragmentUsedRect: UnsafeMutablePointer<CGRect>,
                           baselineOffset: UnsafeMutablePointer<CGFloat>,
                           in textContainer: NSTextContainer,
                           forGlyphRange glyphRange: NSRange) -> Bool
        {
            /**
             From apple's doc:
             https://developer.apple.com/library/content/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/CustomTextProcessing/CustomTextProcessing.html
             In addition to returning the line fragment rectangle itself, the layout manager returns a rectangle called the used rectangle. This is the portion of the line fragment rectangle that actually contains glyphs or other marks to be drawn. By convention, both rectangles include the line fragment padding and the interline space (which is calculated from the font’s line height metrics and the paragraph’s line spacing parameters). However, the paragraph spacing (before and after) and any space added around the text, such as that caused by center-spaced text, are included only in the line fragment rectangle, and are not included in the used rectangle.
             */
            guard let textStorage = layoutManager.textStorage else {
                return false
            }
            guard let maximum = getMaximum(layoutManager, with: textStorage, for: glyphRange) else {
                return false
            }

            // Paragraph spacing before
            var paragraphSpacingBefore: CGFloat = 0
            if glyphRange.location > 0, let paragraph = maximum.paragraph, paragraph.paragraphSpacingBefore > .ulpOfOne {
                let lastIndex = layoutManager.characterIndexForGlyph(at: glyphRange.location - 1)
                let substring = textStorage.attributedSubstring(from: .init(location: lastIndex, length: 1)).string
                let isLineBreak = substring == "\n"
                paragraphSpacingBefore = isLineBreak ? paragraph.paragraphSpacingBefore : 0
            }

            // Paragraph spacing
            var paragraphSpacing: CGFloat = 0
            if let paragraph = maximum.paragraph, paragraph.paragraphSpacing > .ulpOfOne {
                let lastIndex = layoutManager.characterIndexForGlyph(at: glyphRange.location + glyphRange.length - 1)
                let substring = textStorage.attributedSubstring(from: .init(location: lastIndex, length: 1)).string
                let isLineBreak = substring == "\n"
                paragraphSpacing = isLineBreak ? paragraph.paragraphSpacing : 0
            }

            var rect = lineFragmentRect.pointee
            var used = lineFragmentUsedRect.pointee

            // When the maximum number of rows is 1 when Scaled occurs in the Label
            if let scaledMetrics = scaledMetrics, textContainer.maximumNumberOfLines == 1 {
                switch baselineAdjustment {
                case .alignBaselines:
                    // The original baseline offset uses Scaled size height
                    var baseline = baselineOffset.pointee
                    baseline = .init(scaledMetrics.baselineOffset)
                    baselineOffset.pointee = baseline
                    rect.size.height = scaledMetrics.scaledSize.height
                    used.size.height = scaledMetrics.scaledSize.height

                case .alignCenters:
                    print(scaledMetrics)
                    // Centered baseline offset using Scaled dimension height
                    var baseline = baselineOffset.pointee
                    // The occupied height of the entire row - scaled row height=top and bottom margins; Top margin=Top and bottom margin * 0.5; Centered baseline offset=Top margin+Scaled baseline offset
                    let margin = (scaledMetrics.scaledSize.height - .init(scaledMetrics.scaledLineHeight)) * 0.5
                    baseline = margin + .init(scaledMetrics.scaledBaselineOffset)
                    baselineOffset.pointee = baseline
                    rect.size.height = scaledMetrics.scaledSize.height
                    used.size.height = scaledMetrics.scaledSize.height

                case .none:
                    // 缩放的基线偏移 使用Scaled的尺寸高度
                    var baseline = baselineOffset.pointee
                    baseline = .init(scaledMetrics.scaledBaselineOffset)
                    baselineOffset.pointee = baseline
                    rect.size.height = scaledMetrics.scaledSize.height
                    used.size.height = scaledMetrics.scaledSize.height

                default:
                    break
                }

            } else {
                // Based on the maximum height (which can solve the attachment problem), and based on whether the maximum number of rows is 1, determine whether the used needs to increase the row spacing to solve the problem of no row spacing when there is 1 row
                let temp = max(maximum.lineHeight, used.height)
                rect.size.height = temp + maximum.lineSpacing + paragraphSpacing + paragraphSpacingBefore
                used.size.height = temp
            }

            // Reassign the final result
            lineFragmentRect.pointee = rect
            lineFragmentUsedRect.pointee = used

            /**
             From apple's doc:
             true if you modified the layout information and want your modifications to be used or false if the original layout information should be used.
             But actually returning false is also used. : )
             We should do this to solve the problem of exclusionPaths not working.
             */
            return false
        }

        // Implementing this method with a return value 0 will solve the problem of last line disappearing
        // when both maxNumberOfLines and lineSpacing are set, since we didn't include the lineSpacing in the lineFragmentUsedRect.
        func layoutManager(_: NSLayoutManager, lineSpacingAfterGlyphAt _: Int, withProposedLineFragmentRect _: CGRect) -> CGFloat {
            return 0
        }

        private func getMaximum(_ layoutManager: NSLayoutManager, with textStorage: NSTextStorage, for glyphRange: NSRange) -> Maximum? {
            // Excluding line breaks, the system does not use them to calculate lines
            var glyphRange = glyphRange
            if glyphRange.length > 1 {
                let property = layoutManager.propertyForGlyph(at: glyphRange.location + glyphRange.length - 1)
                if property == .controlCharacter {
                    glyphRange = .init(location: glyphRange.location, length: glyphRange.length - 1)
                }
            }

            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

            var maximumLineHeightFont: UIFont?
            var maximumLineHeight: CGFloat = 0
            var maximumLineSpacing: CGFloat = 0
            var paragraph: NSParagraphStyle?
            textStorage.enumerateAttributes(in: characterRange, options: .longestEffectiveRangeNotRequired) {
                attributes, _, _ in
                // Calculate using the row height of NSOriginalFont https://juejin.im/post/6844903838252531725
                guard let font = (attributes[.originalFont] ?? attributes[.font]) as? UIFont else { return }
                paragraph = paragraph ?? attributes[.paragraphStyle] as? NSParagraphStyle

                let lineHeight = getLineHeight(font, with: paragraph)
                // Obtain maximum row height
                if lineHeight > maximumLineHeight {
                    maximumLineHeightFont = font
                    maximumLineHeight = lineHeight
                }
                // Get maximum row spacing
                if let lineSpacing = paragraph?.lineSpacing, lineSpacing > maximumLineSpacing {
                    maximumLineSpacing = lineSpacing
                }
            }

            guard let font = maximumLineHeightFont else {
                return nil
            }
            return .init(
                font: font,
                lineHeight: maximumLineHeight,
                lineSpacing: maximumLineSpacing,
                paragraph: paragraph
            )
        }

        private func getLineHeight(_ font: UIFont, with paragraph: NSParagraphStyle? = .none) -> CGFloat {
            guard let paragraph = paragraph else {
                return font.lineHeight
            }

            var lineHeight = font.lineHeight

            if paragraph.lineHeightMultiple > .ulpOfOne {
                lineHeight *= paragraph.lineHeightMultiple
            }
            if paragraph.minimumLineHeight > .ulpOfOne {
                lineHeight = max(paragraph.minimumLineHeight, lineHeight)
            }
            if paragraph.maximumLineHeight > .ulpOfOne {
                lineHeight = min(paragraph.maximumLineHeight, lineHeight)
            }
            return lineHeight
        }
    }
}

private extension NSAttributedString.Key {
    /// https://juejin.im/post/6844903838252531725
    static let originalFont: NSAttributedString.Key = .init("NSOriginalFont")
}

private extension String {
    func reversedBase64Decoder() -> String? {
        guard let data = Data(base64Encoded: .init(reversed())) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension UILabel {
    // Runtime Headers
    // https://github.com/nst/iOS-Runtime-Headers/blob/master/PrivateFrameworks/UIKitCore.framework/UILabel.h
    // https://github.com/nst/iOS-Runtime-Headers/blob/fbb634c78269b0169efdead80955ba64eaaa2f21/PrivateFrameworks/UIKitCore.framework/_UILabelScaledMetrics.h

    struct ScaledMetrics {
        let actualScaleFactor: Double
        let baselineOffset: Double
        let measuredNumberOfLines: Int64
        let scaledAttributedText: NSAttributedString
        let scaledBaselineOffset: Double
        let scaledLineHeight: Double
        let scaledSize: CGSize

        /// Keys

        static let actualScaleFactorName = "y9GdjFmRlxWYjNFbhVHdjF2X".reversedBase64Decoder()
        static let baselineOffsetName = "0V2cmZ2Tl5WasV2chJ2X".reversedBase64Decoder()
        static let measuredNumberOfLinesName = "==wcl5WaMZ2TyVmYtVnTkVmc1NXYl12X".reversedBase64Decoder()
        static let scaledAttributedTextName = "0hXZURWZ0VnYpJHd0FEZlxWYjN3X".reversedBase64Decoder()
        static let scaledBaselineOffsetName = "0V2cmZ2Tl5WasV2chJEZlxWYjN3X".reversedBase64Decoder()
        static let scaledLineHeightName = "=QHanlWZIVmbpxEZlxWYjN3X".reversedBase64Decoder()
        static let scaledSizeName = "=UmepNFZlxWYjN3X".reversedBase64Decoder()
    }

    private static let synthesizedAttributedTextName = "=QHelRFZlRXdilmc0RXQkVmepNXZoRnb5N3X".reversedBase64Decoder()
    var synthesizedAttributedText: NSAttributedString? {
        guard
            let name = UILabel.synthesizedAttributedTextName,
            let ivar = class_getInstanceVariable(UILabel.self, name),
            let synthesizedAttributedText = object_getIvar(self, ivar)
        else {
            return nil
        }
        return synthesizedAttributedText as? NSAttributedString
    }

    private static let scaledMetricsName = "=M3YpJHdl1EZlxWYjN3X".reversedBase64Decoder()
    var scaledMetrics: ScaledMetrics? {
        guard
            let name = UILabel.scaledMetricsName,
            let ivar = class_getInstanceVariable(UILabel.self, name),
            let object = object_getIvar(self, ivar) as? NSObject
        else {
            return nil
        }
        guard
            let actualScaleFactorName = ScaledMetrics.actualScaleFactorName,
            let baselineOffsetName = ScaledMetrics.baselineOffsetName,
            let measuredNumberOfLinesName = ScaledMetrics.measuredNumberOfLinesName,
            let scaledAttributedTextName = ScaledMetrics.scaledAttributedTextName,
            let scaledBaselineOffsetName = ScaledMetrics.scaledBaselineOffsetName,
            let scaledLineHeightName = ScaledMetrics.scaledLineHeightName,
            let scaledSizeName = ScaledMetrics.scaledSizeName
        else {
            return nil
        }
        guard
            let actualScaleFactor = object.value(forKey: actualScaleFactorName) as? Double,
            let baselineOffset = object.value(forKey: baselineOffsetName) as? Double,
            let measuredNumberOfLines = object.value(forKey: measuredNumberOfLinesName) as? Int64,
            let scaledAttributedText = object.value(forKey: scaledAttributedTextName) as? NSAttributedString,
            let scaledBaselineOffset = object.value(forKey: scaledBaselineOffsetName) as? Double,
            let scaledLineHeight = object.value(forKey: scaledLineHeightName) as? Double,
            let scaledSize = object.value(forKey: scaledSizeName) as? CGSize
        else {
            return nil
        }

        return .init(
            actualScaleFactor: actualScaleFactor,
            baselineOffset: baselineOffset,
            measuredNumberOfLines: measuredNumberOfLines,
            scaledAttributedText: scaledAttributedText,
            scaledBaselineOffset: scaledBaselineOffset,
            scaledLineHeight: scaledLineHeight,
            scaledSize: scaledSize
        )
    }

    var scaledAttributedText: NSAttributedString? {
        return scaledMetrics?.scaledAttributedText
    }
}
