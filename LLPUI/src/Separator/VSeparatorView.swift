//
//  VSeparatorView.swift
//  LLPUI
//
//  Created by xueqooy on 2024/4/18.
//

import UIKit

public class VSeparatorView: SeparatorView {
    
    public override var orientation: SeparatorView.Orientation {
        willSet {
            precondition(newValue == .vertical, "VSeparator can't modify its orientation as horizontal")
        }
    }
    
    public init(color: UIColor? = Colors.line, thickness: CGFloat = 1, leadingPadding: CGFloat = 0, trailingPadding: CGFloat = 0) {
        super.init(color: color, thickness: thickness, orientation: .vertical, leadingPadding: leadingPadding, trailingPadding: trailingPadding)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}