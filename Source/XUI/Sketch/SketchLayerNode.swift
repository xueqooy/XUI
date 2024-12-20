//
//  SketchLayerNode.swift
//  XUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit

class SketchLayerNode {
    private enum Action {
        case move(relativePoint: CGPoint)
        case addQuadCurve(relativeEndPoint: CGPoint, relativeControlPoint: CGPoint)
    }

    let tool: SketchView.Tool

    private var path = CGMutablePath()
    private var actions = [Action]()
    private var boundingSize: CGSize

    init(tool: SketchView.Tool, startPoint: CGPoint, boundingSize: CGSize) {
        self.tool = tool
        self.boundingSize = boundingSize

        path.move(to: startPoint)

        actions.append(.move(relativePoint: relativePoint(for: startPoint)))
    }

    func move(to point: CGPoint, previousPoint: CGPoint) {
        let endPoint = previousPoint.mid(to: point)
        path.addQuadCurve(to: endPoint, control: previousPoint)

        actions.append(.addQuadCurve(relativeEndPoint: relativePoint(for: endPoint), relativeControlPoint: relativePoint(for: previousPoint)))
    }

    func draw(in ctx: CGContext) {
        let thicknessInPoint = tool.thicknessInPoint(for: boundingSize.width)
        switch tool {
        case let .brush(color, _):
            ctx.setLineWidth(thicknessInPoint)
            ctx.setBlendMode(.normal)
            ctx.setStrokeColor(color.cgColor)
        case .eraser:
            ctx.setLineWidth(thicknessInPoint)
            ctx.setBlendMode(.clear)
        }

        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)

        ctx.addPath(path)
        ctx.strokePath()
    }

    func updateBoundingSize(_ size: CGSize) {
        guard boundingSize != size else {
            return
        }
        boundingSize = size

        path = CGMutablePath()
        for action in actions {
            switch action {
            case let .move(relativePoint):
                path.move(to: absolutePoint(for: relativePoint))
            case let .addQuadCurve(relativeEndPoint, relativeControlPoint):
                path.addQuadCurve(to: absolutePoint(for: relativeEndPoint), control: absolutePoint(for: relativeControlPoint))
            }
        }
    }

    private func relativePoint(for absolutePoint: CGPoint) -> CGPoint {
        guard boundingSize.width > 0 && boundingSize.height > 0 else {
            return .zero
        }

        return CGPoint(x: absolutePoint.x / boundingSize.width, y: absolutePoint.y / boundingSize.height)
    }

    private func absolutePoint(for relativePoint: CGPoint) -> CGPoint {
        return CGPoint(x: relativePoint.x * boundingSize.width, y: relativePoint.y * boundingSize.height)
    }
}
