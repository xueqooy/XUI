//
//  PageControlIndicatorView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/4/12.
//

import UIKit

class PageControlIndicatorView: UIView {

    private struct Constants {
        static let smallSize = CGSize(width: 6.0, height: 6.0)
        static let normalSize = CGSize(width: 12.0, height: 6.0)
        static let selectedSize = CGSize(width: 24.0, height: 6.0)
    }

    var state: PageControl.IndicatorState = .hidden {
        didSet {
            if oldValue == state {
                return
            }

            updateCornerRadius()
            updateBackgroundColor()
        }
    }

    var color: UIColor {
        didSet {
            if oldValue == color {
                return
            }
            
            updateBackgroundColor()
        }
    }

    init(color: UIColor) {
        self.color = color

        super.init(frame: .zero)
                
        updateCornerRadius()
        updateBackgroundColor()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateCornerRadius() {
        switch state {
        case .hidden:
            layer.cornerRadius = 0
        case .small:
            layer.cornerRadius = Constants.smallSize.height * 0.5
        case .normal:
            layer.cornerRadius = Constants.normalSize.height * 0.5
        case .selected:
            layer.cornerRadius = Constants.selectedSize.height * 0.5
        }
    }

    private func updateBackgroundColor() {
        backgroundColor = state == .selected ? color : color.withMultiplicativeAlpha(0.3)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        switch state {
        case .hidden:
            return .zero
        case .small:
            return Constants.smallSize
        case .normal:
            return Constants.normalSize
        case .selected:
            return Constants.selectedSize
        }
    }
}
