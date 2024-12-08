//
//  ViewAllEntitiesViewModel.swift
//  XUI
//
//  Created by xueqooy on 2024/5/31.
//

import UIKit
import IGListDiffKit

class ViewAllEntitiesViewModel: NSObject, ListDiffable, ListCellSizeCacheIdentifiable {

    let additionalCount: Int
    
    let height: CGFloat
    
    init(additionalCount: Int, height: CGFloat) {
        self.additionalCount = additionalCount
        self.height = height
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        "View All" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? ViewAllEntitiesViewModel else {
            return false
        }
        
        return additionalCount == other.additionalCount
    }
    
    var cellSizeCacheId: NSObjectProtocol {
        additionalCount as NSObjectProtocol
    }
}
