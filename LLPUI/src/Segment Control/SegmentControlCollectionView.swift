//
//  SegmentControlCollectionView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit

class SegmentControlCollectionView: UICollectionView {
    weak var indicatorView: SegmentControlIndicatorView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let indicatorView = indicatorView {
            sendSubviewToBack(indicatorView)
        }
    }
}
