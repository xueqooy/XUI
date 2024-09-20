//
//  ListSectionBackgroundDecorationView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/15.
//

import UIKit
import LLPUtils

class ListSectionBackgroundDecorationView: UICollectionReusableView {
    private lazy var view = BackgroundView(configuration: .overlay()).then { self.addSubview($0) }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let layoutAttributes = layoutAttributes as? ListSectionBackgroundDecorationViewLayoutAttributes else {
            return
        }
        
        view.frame = bounds
        view.configuration = layoutAttributes.configuration
    }
}
