//
//  ListToastSectionController.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/5.
//

import Foundation
import IGListKit
import Combine

class ListToastSectionController: ListBindingSectionController<ListToastObject> {
    
    private var cancellable: AnyCancellable?
    
    override init() {
        super.init()
        
        dataSource = self
    }
    
    override func didUpdate(to object: Any) {
        super.didUpdate(to: object)
        
        let object = object as! ListToastObject
        
        inset = object.inset
        
        cancellable = object.stateDidChange
            .sink { [weak self] in
                guard let self = self else {
                    return
                }
            
                self.update(animated: true)
            }
    }
}

extension ListToastSectionController: ListBindingSectionControllerDataSource {
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        [ListToastViewModel(object: object as! ListToastObject)]
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        dequeueReusableCell(of: ListToastCell.self, at: index)
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        managedCellSize(of: ListToastCell.self, for: viewModel as! ListCellSizeCacheIdentifiable)
    }
}
