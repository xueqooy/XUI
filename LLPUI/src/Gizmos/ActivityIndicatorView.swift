//
//  ActivityIndicator.swift
//  LLPUI
//
//  Created by xueqooy on 2023/4/11.
//

import UIKit

public class ActivityIndicatorView: UIActivityIndicatorView {
    
    public init(color: UIColor = Colors.teal) {
        super.init(frame: .zero)
        
        self.color = color
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
