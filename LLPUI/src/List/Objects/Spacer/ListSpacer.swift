//
//  ListSpacer.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/25.
//

import Foundation
import IGListDiffKit

/// Spacer used in vertical or horizontal list
open class ListSpacer {
    public let identifier: String
    public let spacing: CGFloat
    
    public init(identifier: String = UUID().uuidString, spacing: CGFloat) {
        self.identifier = identifier
        self.spacing = spacing
    }
}

extension ListSpacer: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        identifier as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let viewModel = object as? ListSpacer else {
            return false
        }
        return self.spacing == viewModel.spacing
    }
}

extension ListSpacer: ListCellSizeCacheIdentifiable {
}
