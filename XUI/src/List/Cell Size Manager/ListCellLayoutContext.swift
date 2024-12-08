//
//  ListLayoutContext.swift
//  XUI
//
//  Created by xueqooy on 2024/5/30.
//

import UIKit

public struct ListCellLayoutContext: Hashable {
    
    public let scrollDirection: UICollectionView.ScrollDirection
    
    /// Section container width for vertical scroll direction, or height for horizontal scroll direction.
    public let sectionScrollCrossAxisExtent: CGFloat
    
    public init(scrollDirection: UICollectionView.ScrollDirection = .vertical, sectionScrollCrossAxisExtent: CGFloat = 0) {
        self.scrollDirection = scrollDirection
        self.sectionScrollCrossAxisExtent = sectionScrollCrossAxisExtent
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(scrollDirection)
        hasher.combine(sectionScrollCrossAxisExtent)
    }
    
    public func stretchedSize(withScrollAxisExtent scrollAxisExtent: CGFloat) -> CGSize {
        if scrollDirection == .vertical {
            CGSize(width: sectionScrollCrossAxisExtent, height: scrollAxisExtent)
        } else {
            CGSize(width: scrollAxisExtent, height: sectionScrollCrossAxisExtent)
        }
    }
}
