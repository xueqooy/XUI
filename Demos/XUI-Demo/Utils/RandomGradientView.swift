//
//  RandomGradientView.swift
//  XUI_Example
//
//  Created by xueqooy on 2023/7/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI

class RandomGradientView: UIView {
    var intrinsicSize: CGSize = .zero {
        didSet {
            guard oldValue != intrinsicSize else { return }

            invalidateIntrinsicContentSize()
        }
    }

    let gradientLayer = createGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(gradientLayer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = layer.bounds
    }

    override var intrinsicContentSize: CGSize {
        intrinsicSize
    }
}

class RandomGradientScrollView: UIScrollView {
    let gradientLayer = createGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(gradientLayer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: layer.bounds.width, height: contentSize.height)
    }
}

private func createGradientLayer() -> CAGradientLayer {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [UIColor.randomColor().cgColor, UIColor.randomColor().cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    return gradientLayer
}
