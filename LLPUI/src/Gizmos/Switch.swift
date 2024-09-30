//
//  Switch.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/10.
//

import Foundation

open class Switch: UISwitch {
    
    open override var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            
            subviews.forEach {
                $0.alpha = isEnabled ? 1.0 : 0.5
            }
        }
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        initialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {
        onTintColor = Colors.green
        
        subviews.first?.subviews.first?.backgroundColor = Colors.disabledText
        
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
}
