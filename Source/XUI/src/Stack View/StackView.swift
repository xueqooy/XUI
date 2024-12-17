//
//  StackView.swift
//  XUI
//
//  Created by xueqooy on 2023/11/6.
//

import UIKit

public class StackView: UIStackView {

    public convenience init(distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 0, layoutMargins: UIEdgeInsets? = nil) {
        self.init(frame: .zero)
        
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        
        if let layoutMargins = layoutMargins {
            self.layoutMargins = layoutMargins
            isLayoutMarginsRelativeArrangement = true
        }
    }
    
    public convenience init(distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 0, layoutMargins: UIEdgeInsets? = nil, @ViewBuilder views: () -> [UIView]) {
        let views = views()
        
        self.init(arrangedSubviews:  views)
                
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        
        if let layoutMargins = layoutMargins {
            self.layoutMargins = layoutMargins
            isLayoutMarginsRelativeArrangement = true
        }
    }
    
    public func populate(keepPreviousViews: Bool = false, @ViewBuilder views: () -> [UIView]) {
        if !keepPreviousViews {
            arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
        
        views().forEach { addArrangedSubview($0) }
    }
    
    public override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        if arrangedSubviews.contains(subview) {
            subview.maybeApplyCustomSpacingAfter()
        }
    }
}
