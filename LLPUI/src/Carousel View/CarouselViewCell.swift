//
//  CarouselViewCell.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/22.
//

import UIKit

class CarouselViewCell<Content : BindingView>: UICollectionViewCell {
    var content: Content? {
        didSet {
            guard let content = content else {
                content?.removeFromSuperview()
                return
            }
            
            contentView.addSubview(content)
            content.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? .LLPUI.highlightAlpha : 1
        }
    }
}
