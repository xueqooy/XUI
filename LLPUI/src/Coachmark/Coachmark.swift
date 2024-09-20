//
//  Coachmark.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/3.
//

import UIKit

public class Coachmark {
    public let rect: CGRect
    public let cutoutCornerStyle: CornerStyle
    public let contentView: UIView
    
    private var cutoutCornerRadius: CGFloat {
        switch cutoutCornerStyle {
        case .capsule:
            return rect.height / 2
        case .fixed(let value):
            return value
        }
    }
    
    public init(rect: CGRect, cutoutCornerStyle: CornerStyle, contentView: UIView) {
        self.rect = rect
        self.cutoutCornerStyle = cutoutCornerStyle
        self.contentView = contentView
    }
    
    func maskPath(for boundingRect: CGRect) -> CGPath {
        let cutoutPath = UIBezierPath(roundedRect: rect, cornerRadius: cutoutCornerRadius)
        cutoutPath.usesEvenOddFillRule = true
        
        let path = UIBezierPath(rect: boundingRect)
        path.append(cutoutPath)
        
        return path.cgPath
    }
}
