//
//  SpacerView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/3.
//

import UIKit

public class SpacerView: UIView {
    
    public enum Orientation {
        case horizontal
        case vertical
        
        var layoutAxis: NSLayoutConstraint.Axis {
            switch self {
            case .horizontal:
                return .horizontal
            case .vertical:
                return .vertical
            }
        }
    }
    
    public var spacing: CGFloat = 0 {
        didSet {
            guard spacing != oldValue else {
                return
            }
            
            invalidateIntrinsicContentSize()
        }
    }
    
    public var huggingPriority: UILayoutPriority {
        set {
            setContentHuggingPriority(newValue, for: orientation.layoutAxis)
        }
        get {
            contentHuggingPriority(for: orientation.layoutAxis)
        }
    }
    
    
    public var compressionResistancePriority: UILayoutPriority {
        set {
            setContentCompressionResistancePriority(newValue, for: orientation.layoutAxis)
        }
        get {
            contentHuggingPriority(for: orientation.layoutAxis)
        }
    }
    
    public var orientation: Orientation {
        didSet {
            guard oldValue != orientation else {
                return
            }
            
            invalidateIntrinsicContentSize()
        }
    }
    
    public class func flexible(_ orientation: Orientation = .horizontal) -> SpacerView {
        SpacerView(.greatestFiniteMagnitude, orientation: orientation, huggingPriority: .fittingSizeLevel, compressionResistancePriority: .fittingSizeLevel)
    }
    
    public init(_ spacing: CGFloat = 0, orientation: Orientation = .horizontal, huggingPriority: UILayoutPriority = .dragThatCannotResizeScene, compressionResistancePriority: UILayoutPriority = .dragThatCannotResizeScene) {
        self.spacing = spacing
        self.orientation = orientation
        
        super.init(frame: .zero)
        
        self.compressionResistancePriority = compressionResistancePriority
        self.huggingPriority = huggingPriority
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var intrinsicContentSize: CGSize {
        switch orientation {
        case .horizontal:
            return CGSize(width: spacing, height: UIView.noIntrinsicMetric)
        case .vertical:
            return CGSize(width: UIView.noIntrinsicMetric, height: spacing)
        }
    }
}
