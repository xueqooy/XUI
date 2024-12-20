//
//  ListSectionConnectionDecorationView.swift
//  XUI
//
//  Created by xueqooy on 2023/10/5.
//

import UIKit
import XKit
import XUI

class ListSectionConnectionDecorationView: UICollectionReusableView {
    private var direction: ListSectionConnectionDecorationViewLayoutAttributes.DrawingDirection?

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.isOpaque = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let direction = direction, rect.width > 0 && rect.height > 0, let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let lineWidth: CGFloat = 1

        switch direction {
        case .leftToRight:
            var radius: CGFloat = .XUI.smallCornerRadius
            if rect.maxY < radius || rect.maxX < radius {
                radius = max(0, min(rect.maxY, rect.maxX))
            }

            context.translateBy(x: lineWidth / 2, y: -lineWidth / 2)

            let startPointOfCorner = CGPoint(x: rect.minX, y: rect.maxY - radius)
            let endPointOfCorner = CGPoint(x: radius, y: rect.maxY)
            let centerPoint = CGPoint(x: endPointOfCorner.x, y: startPointOfCorner.y)

            context.move(to: rect.origin)
            context.addLine(to: startPointOfCorner)
            context.addArc(center: centerPoint, radius: radius, startAngle: .pi, endAngle: 0.5 * .pi, clockwise: true)
            context.addLine(to: .init(x: rect.maxX, y: rect.maxY))

        case .vertical:
            context.translateBy(x: lineWidth / 2, y: 0)

            context.move(to: rect.origin)
            context.addLine(to: .init(x: rect.minX, y: rect.maxY))

        case .rightToLeft:
            var radius: CGFloat = .XUI.smallCornerRadius
            if rect.maxY < radius || rect.maxX < radius {
                radius = max(0, min(rect.maxY, rect.maxX))
            }

            context.translateBy(x: -lineWidth / 2, y: -lineWidth / 2)

            let startPointOfCorner = CGPoint(x: rect.maxX, y: rect.maxY - radius)
            let endPointOfCorner = CGPoint(x: rect.maxX - radius, y: rect.maxY)
            let centerPoint = CGPoint(x: endPointOfCorner.x, y: startPointOfCorner.y)

            context.move(to: .init(x: rect.maxX, y: 0))
            context.addLine(to: startPointOfCorner)
            context.addArc(center: centerPoint, radius: radius, startAngle: 0, endAngle: 0.5 * .pi, clockwise: false)
            context.addLine(to: .init(x: rect.minX, y: rect.maxY))
        }

        context.setLineWidth(lineWidth)
        context.setLineJoin(.round)
        context.setStrokeColor(Colors.line2.cgColor)

        context.strokePath()
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        guard let layoutAttributes = layoutAttributes as? ListSectionConnectionDecorationViewLayoutAttributes else {
            return
        }

        direction = layoutAttributes.direction

        setNeedsDisplay()
    }
}
