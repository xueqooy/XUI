//
//  ListEmptyViewModel.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/5.
//

import Foundation
import IGListDiffKit

class ListEmptyViewModel {
    private let object: ListEmptyObject
    
    let configuration: EmptyView.Configuration
    
    init(object: ListEmptyObject) {
        self.object = object
        
        configuration = object.configuration
    }
}

extension ListEmptyViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        object.diffIdentifier()
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let viewModel = object as? ListEmptyViewModel else {
            return false
        }
        
        return configuration == viewModel.configuration
    }
}
 
extension ListEmptyViewModel: ListCellSizeCacheIdentifiable {}
