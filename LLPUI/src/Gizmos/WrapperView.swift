//
//  WrapperView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/4/10.
//

import UIKit
import SnapKit

/// Wrap a view, adjust content margins by setting `layoutMargins`
public class WrapperView: UIView {
    
    var intrinsicSize: CGSize? {
        didSet {
            if oldValue == intrinsicSize {
                return
            }
            
            invalidateIntrinsicContentSize()
        }
    }
    
    public init(_ view: UIView, layoutMargins: UIEdgeInsets = .zero, intrinsicSize: CGSize? = nil) {
        super.init(frame: .zero)
        
        self.layoutMargins = layoutMargins
        self.intrinsicSize = intrinsicSize
        
        addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalTo(snp.margins)
        }
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        intrinsicSize ?? super.intrinsicContentSize
    }
}


