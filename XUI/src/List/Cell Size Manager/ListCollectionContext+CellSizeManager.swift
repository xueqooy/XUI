//
//  ListCellSizeManager+Shared.swift
//  XUI
//
//  Created by xueqooy on 2023/8/10.
//

import Foundation
import IGListKit
import XKit

private var cellSizeManagerMapAssociation = Association<[String : Any]>(wrap: .retain)

extension ListCollectionContext {
    
    var cellSizeManagerMap: [String : Any] {
        get {
            cellSizeManagerMapAssociation[self] ?? [:]
        }
        set {
            cellSizeManagerMapAssociation[self] = newValue
        }
    }
    
    func cellSizeManager<Cell>(of _: Cell.Type) -> ListCellSizeManager<Cell> {
        let cellClassString = NSStringFromClass(Cell.self)

        if let cellSizeManager = cellSizeManagerMap[cellClassString] as? ListCellSizeManager<Cell> {
            return cellSizeManager
        }
        
        let cellSizeManager: ListCellSizeManager<Cell> = .init()
        cellSizeManagerMap[cellClassString] = cellSizeManager

        return cellSizeManager
    }
    
}
