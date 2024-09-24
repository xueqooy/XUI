//
//  HSeparatorView.swift
//  LLPUI
//
//  Created by xueqooy on 2024/4/18.
//

import UIKit

public class HSeparatorView: SeparatorView {
    
    public override var orientation: SeparatorView.Orientation {
        willSet {
            precondition(newValue == .horizontal, "HSeparator can't modify its orientation as vertical")
        }
    }
    
    public init(color: UIColor? = Colors.line2, thickness: CGFloat = 1, leadingPadding: CGFloat = 0, trailingPadding: CGFloat = 0) {
        super.init(color: color, thickness: thickness, orientation: .horizontal, leadingPadding: leadingPadding, trailingPadding: trailingPadding)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
