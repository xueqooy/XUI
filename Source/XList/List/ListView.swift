//
//  ListView.swift
//  XUI
//
//  Created by xueqooy on 2023/9/11.
//

import UIKit
import XUI

public class ListView: UICollectionView {
        
    /// Whether to treat the content size  as the intrinsic content size
    public var automaticallyUpdatesIntrinsicContentSize: Bool = false {
        didSet {
            guard oldValue != automaticallyUpdatesIntrinsicContentSize else {
                return
            }
            
            invalidateIntrinsicContentSize()
        }
    }
    
    var layout: ListLayout!
    
    init(scrollDirection: ScrollDirection = .vertical) {
        let layout = ListLayout(scrollDirection: scrollDirection)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        self.layout = layout
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        backgroundColor = .clear
        
        if layout.scrollDirection == .vertical {
            alwaysBounceVertical = true
        } else {
            alwaysBounceHorizontal = true
        }
        
        isEndEditingTapGestureEnabled = true
        automaticallyAdjustsBottomInsetBasedOnKeyboardHeight = true
        makesFirstResponderVisibleWhenKeyboardHeightChange = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard automaticallyUpdatesIntrinsicContentSize else { return }
        
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        if automaticallyUpdatesIntrinsicContentSize {
            let contentSize = contentSize
            let adjustedContentInset = adjustedContentInset
            
            return CGSize(width: contentSize.width + adjustedContentInset.horizontal, height: contentSize.height + adjustedContentInset.vertical)
        } else {
            return super.intrinsicContentSize
        }
    }
}

extension ListView: NestedScrollingContent {
    public var childScrollView: UIScrollView? {
        self
    }
}
