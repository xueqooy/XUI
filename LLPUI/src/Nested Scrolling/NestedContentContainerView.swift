//
//  NestedContentContainerView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/7/25.
//

import UIKit

/**
 The purpose of using ScrollView as a container:
 1. When `bounceTarget` is `child`, the dropdown can trigger the scrolling offset change of `childScrollView`
 2. When the scrolling deceleration reaches the critical point, it can trigger the rolling offset change of `childScrollView`
 */

class NestedContentContainerView: UIScrollView {
    var contentView: NestedScrollingContent? {
        didSet {
            oldValue?.removeFromSuperview()
            
            guard let contentView = contentView else {
                return
            }
            
            addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.size.equalToSuperview()
                make.top.left.equalToSuperview()
            }
        }
    }
}
