//
//  ListSpacerSectionController.swift
//  XUI
//
//  Created by xueqooy on 2023/10/26.
//

import IGListKit
import UIKit

class ListSpacerSectionController: ListGenericSectionController<ListSpacer> {
    override func sizeForItem(at _: Int) -> CGSize {
        managedCellSize(of: ListSpacerCell.self, for: object)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        dequeueReusableCell(of: ListSpacerCell.self, at: index)
    }
}
