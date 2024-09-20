//
//  ActivityIndicator.swift
//  LLPUI
//
//  Created by xueqooy on 2023/4/11.
//

import UIKit

public class ActivityIndicatorView: UIActivityIndicatorView {
    
    public init() {
        super.init(frame: .zero)
        
        color = Colors.teal
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
