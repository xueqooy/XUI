//
//  RefreshControl.swift
//  XUI
//
//  Created by xueqooy on 2023/9/11.
//

import UIKit

public class RefreshControl: UIRefreshControl {
    public convenience override init() {
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
        tintColor = Colors.teal
    }
}
