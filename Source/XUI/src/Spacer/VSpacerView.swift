//
//  VSpacerView.swift
//  XUI
//
//  Created by xueqooy on 2024/4/18.
//

import UIKit

public class VSpacerView: SpacerView {
    
    public override var orientation: SpacerView.Orientation {
        willSet {
            precondition(newValue == .horizontal, "VSpacerView can't modify its orientation as horizontal")
        }
    }
    
    public static func flexible() -> VSpacerView {
        VSpacerView(.greatestFiniteMagnitude, huggingPriority: .fittingSizeLevel, compressionResistancePriority: .fittingSizeLevel)
    }
    
    public init(_ spacing: CGFloat, huggingPriority: UILayoutPriority = .dragThatCannotResizeScene, compressionResistancePriority: UILayoutPriority = .dragThatCannotResizeScene) {
        super.init(spacing, orientation: .vertical, huggingPriority: huggingPriority, compressionResistancePriority: compressionResistancePriority)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
