//
//  HSpacerView.swift
//  XUI
//
//  Created by xueqooy on 2024/4/18.
//

import UIKit

public class HSpacerView: SpacerView {
    
    public override var orientation: SpacerView.Orientation {
        willSet {
            precondition(newValue == .horizontal, "HSpacerView can't modify its orientation as vertical")
        }
    }
    
    public static func flexible() -> HSpacerView {
        HSpacerView(.greatestFiniteMagnitude, huggingPriority: .fittingSizeLevel, compressionResistancePriority: .fittingSizeLevel)
    }
    
    public init(_ spacing: CGFloat, huggingPriority: UILayoutPriority = .dragThatCannotResizeScene, compressionResistancePriority: UILayoutPriority = .dragThatCannotResizeScene) {
        super.init(spacing, orientation: .horizontal, huggingPriority: huggingPriority, compressionResistancePriority: compressionResistancePriority)        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
