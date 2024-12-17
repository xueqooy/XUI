//
//  VStackView.swift
//  XUI
//
//  Created by xueqooy on 2023/11/3.
//

import UIKit

public class VStackView: StackView {
    
    public override var axis: NSLayoutConstraint.Axis {
        willSet {
            precondition(newValue == .vertical, "VStack can't modify its axis as horizontal")
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .vertical
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
