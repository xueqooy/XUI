//
//  ListSpinner.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/30.
//

import Foundation
import IGListDiffKit

/// Spinner used in vertical or horizontal list
public class ListSpinner {
    public let identifier: String
    public let extent: CGFloat
    
    public init(identifier: String = UUID().uuidString, extent: CGFloat = 60) {
        self.identifier = identifier
        self.extent = extent
    }
}

extension ListSpinner: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        identifier as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let viewModel = object as? ListSpinner else {
            return false
        }
        return self.extent == viewModel.extent
    }
}

extension ListSpinner: ListCellSizeCacheIdentifiable {
}
