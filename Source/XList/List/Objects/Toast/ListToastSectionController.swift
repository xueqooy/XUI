//
//  ListToastSectionController.swift
//  XUI
//
//  Created by xueqooy on 2024/1/5.
//

import Combine
import Foundation
import IGListDiffKit
import IGListKit

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
    func sectionController(_: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        [ListToastViewModel(object: object as! ListToastObject)]
    }

    func sectionController(_: ListBindingSectionController<ListDiffable>, cellForViewModel _: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        dequeueReusableCell(of: ListToastCell.self, at: index)
    }

    func sectionController(_: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at _: Int) -> CGSize {
        managedCellSize(of: ListToastCell.self, for: viewModel as! ListCellSizeCacheIdentifiable)
    }
}
