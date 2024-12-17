//
//  HStackView.swift
//  XUI
//
//  Created by xueqooy on 2023/11/3.
//

import UIKit

public class HStackView: StackView {
    
    public override var axis: NSLayoutConstraint.Axis {
        willSet {
            precondition(newValue == .horizontal, "HStack can't modify its axis as vertical")
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .horizontal
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
