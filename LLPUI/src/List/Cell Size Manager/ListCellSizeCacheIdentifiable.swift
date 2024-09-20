//
//  ListCellSizeCacheIdentifiable.swift
//  LLPUI
//
//  Created by xueqooy on 2023/11/10.
//

import Foundation
import IGListDiffKit
import IGListSwiftKit

public protocol ListCellSizeCacheIdentifiable {
    var cellSizeCacheId: NSObjectProtocol { get }
}


public extension ListCellSizeCacheIdentifiable where Self : ListDiffable {
    var cellSizeCacheId: NSObjectProtocol {
        diffIdentifier()
    }
}

public extension ListCellSizeCacheIdentifiable where Self : ListIdentifiable {
    var cellSizeCacheId: NSObjectProtocol {
        diffIdentifier
    }
}


extension String: ListCellSizeCacheIdentifiable {
    public var cellSizeCacheId: NSObjectProtocol {
        self as NSObjectProtocol
    }
}
