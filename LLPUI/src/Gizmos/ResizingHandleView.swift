//
//  ResizingHandleView.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/9/14.
//

import Foundation

// MARK: - ResizingHandleView

open class ResizingHandleView: UIView {
    private struct Constants {
        static let markSize = CGSize(width: 53, height: 5)
        static let markCornerRadius: CGFloat = 2.5
    }

    public static let height: CGFloat = 21

    private let markLayer: CALayer = {
        let markLayer = CALayer()
        markLayer.bounds.size = Constants.markSize
        markLayer.cornerRadius = Constants.markCornerRadius
        markLayer.backgroundColor = Colors.line2.cgColor
        return markLayer
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        self.frame.size.height = ResizingHandleView.height
        autoresizingMask = .flexibleWidth
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        isUserInteractionEnabled = false
        layer.addSublayer(markLayer)
    }

    public required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: ResizingHandleView.height)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: ResizingHandleView.height)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        markLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
