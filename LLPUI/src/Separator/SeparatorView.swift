//
//  SeparatorView.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/9/14.
//

import UIKit
import SnapKit

public class SeparatorView: UIView {
    
    public enum Orientation {
        case horizontal
        case vertical
    }
    
    public var leadingPadding: CGFloat = 0 {
        didSet {
            guard oldValue != leadingPadding else {
                return
            }
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public var trailingPadding: CGFloat = 0 {
        didSet {
            guard oldValue != trailingPadding else {
                return
            }
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public var color: UIColor? {
        set {
            lineView.backgroundColor = newValue
        }
        get {
            lineView.backgroundColor
        }
    }
    
    public var orientation: Orientation {
        didSet {
            guard oldValue != orientation else {
                return
            }
            
            updateLineView()
        }
    }
    
    public var thickness: CGFloat {
        didSet {
            guard oldValue != thickness else {
                return
            }
            
            updateLineView()
        }
    }

    private var lineView = UIView()


    public init(color: UIColor? = Colors.line2, thickness: CGFloat = 1, orientation: Orientation = .horizontal, leadingPadding: CGFloat = 0, trailingPadding: CGFloat = 0) {
        self.thickness = thickness
        self.orientation = orientation
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        
        super.init(frame: .zero)
        
        addSubview(lineView)
        
        self.color = color
        
        updateLineView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLineView() {
        switch orientation {
        case .horizontal:
            frame.size.height = thickness
            autoresizingMask = .flexibleWidth
        case .vertical:
            frame.size.width = thickness
            autoresizingMask = .flexibleHeight
        }
        isAccessibilityElement = false
        isUserInteractionEnabled = false
        
        switch orientation {
        case .horizontal:
            setContentCompressionResistancePriority(.required, for: .vertical)
            setContentHuggingPriority(.required, for: .vertical)
        case .vertical:
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentHuggingPriority(.required, for: .horizontal)
        }
        
        invalidateIntrinsicContentSize()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
                
        switch orientation {
        case .horizontal:
            lineView.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: leadingPadding, bottom: 0, right: trailingPadding))
        case .vertical:
            lineView.frame = bounds.inset(by: UIEdgeInsets(top: leadingPadding, left: 0, bottom: trailingPadding, right: 0))
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        switch orientation {
        case .horizontal:
            return CGSize(width: UIView.noIntrinsicMetric, height: frame.height)
        case .vertical:
            return CGSize(width: frame.width, height: UIView.noIntrinsicMetric)
        }
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        switch orientation {
        case .horizontal:
            return CGSize(width: size.width, height: frame.height)
        case .vertical:
            return CGSize(width: frame.width, height: size.height)
        }
    }
}

