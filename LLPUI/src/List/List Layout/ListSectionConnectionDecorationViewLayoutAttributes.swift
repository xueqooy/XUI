//
//  ListSectionConnectionDecorationViewLayoutAttributes.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/5.
//

import UIKit

class ListSectionConnectionDecorationViewLayoutAttributes: UICollectionViewLayoutAttributes {
        
    enum DrawingDirection {
        case leftToRight, vertical, rightToLeft
    }
    
    var direction: DrawingDirection = .leftToRight
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ListSectionConnectionDecorationViewLayoutAttributes
        copy.direction = direction
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ListSectionConnectionDecorationViewLayoutAttributes else {
            return false
        }

        if self.direction != object.direction {
            return false
        }
        
        return super.isEqual(object)
    }
    
}
