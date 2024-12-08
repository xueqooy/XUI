//
//  ListEmptySectionController.swift
//  XUI
//
//  Created by xueqooy on 2024/1/5.
//

import Foundation
import IGListKit
import Combine

class ListEmptySectionController: ListBindingSectionController<ListEmptyObject> {
    
    private var cancellable: AnyCancellable?
    
    override init() {
        super.init()
        
        dataSource = self
    }
    
    override func didUpdate(to object: Any) {
        super.didUpdate(to: object)
        
        let object = object as! ListEmptyObject
        cancellable = object.stateDidChange 
            // Keep loading to avoid briefly displaying empty views after loading data
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else {
                    return
                }
            
                self.update(animated: true)
            }
    }
}

extension ListEmptySectionController: ListBindingSectionControllerDataSource {
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        [ListEmptyViewModel(object: object as! ListEmptyObject)]
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        dequeueReusableCell(of: ListEmptyCell.self, at: index)
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        managedCellSize(of: ListEmptyCell.self, for: viewModel as! ListCellSizeCacheIdentifiable)
    }
}
