//
//  ListToastViewModel.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/5.
//

import Foundation
import IGListDiffKit

class ListToastViewModel {
    private let object: ListToastObject
    
    let configuration: ListToastObject.Configuration
    
    init(object: ListToastObject) {
        self.object = object
        
        configuration = object.configuration
    }
}

extension ListToastViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        object.diffIdentifier()
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let viewModel = object as? ListToastViewModel else {
            return false
        }
        
        return configuration == viewModel.configuration
    }
}
 
extension ListToastViewModel: ListCellSizeCacheIdentifiable {}
