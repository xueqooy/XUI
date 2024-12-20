//
//  InsetLabel.swift
//  XUI
//
//  Created by xueqooy on 2023/2/23.
//

import UIKit

open class InsetLabel: UILabel {
    public var inset: Insets = .nondirectionalZero {
        didSet {
            guard oldValue != inset else { return }

            setNeedsDisplay()
        }
    }

    public var ignoresInsetForEmptyText: Bool = false {
        didSet {
            if oldValue != ignoresInsetForEmptyText {
                invalidateIntrinsicContentSize()
            }
        }
    }

    public var automaticallySetRoundCorner = false {
        didSet {
            guard oldValue != automaticallySetRoundCorner else { return }

            if automaticallySetRoundCorner {
                layer.cornerRadius = bounds.height / 2
            }
        }
    }

    private var effectiveInset: UIEdgeInsets {
        inset.edgeInsets(for: effectiveUserInterfaceLayoutDirection)
    }

    override open func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        if automaticallySetRoundCorner {
            layer.cornerRadius = bounds.height / 2
        }
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let shouldIgnoreInset = ignoresInsetForEmptyText && (text ?? "").isEmpty

        var result: CGSize
        let horizontalInset = shouldIgnoreInset ? 0 : inset.horizontal
        let verticalInset = shouldIgnoreInset ? 0 : inset.vertical
        result = super.sizeThatFits(CGSize(width: size.width - horizontalInset, height: size.height - verticalInset))
        result.width += horizontalInset
        result.height += verticalInset
        return result
    }

    override public var intrinsicContentSize: CGSize {
        var preferredMaxLayoutWidth = self.preferredMaxLayoutWidth
        if preferredMaxLayoutWidth <= 0 {
            preferredMaxLayoutWidth = CGFloat.greatestFiniteMagnitude
        }
        return sizeThatFits(CGSize(width: preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude))
    }

    override public func drawText(in rect: CGRect) {
        var drawRect = rect.inset(by: effectiveInset)

        if numberOfLines == 1 && (lineBreakMode == .byWordWrapping || lineBreakMode == .byCharWrapping) {
            drawRect.size.height = (drawRect.height + effectiveInset.top * 2).flatInPixel()
        }

        super.drawText(in: drawRect)
    }
}
