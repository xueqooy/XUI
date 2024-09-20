//
//  HUDTextView.swift
//  LLPUI
//
//  Created by xueqooy on 2024/6/18.
//

import Foundation

class HUDTextView: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        textStyleConfiguration = .hudText
        numberOfLines = 0        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
