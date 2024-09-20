//
//  ListSpacerSectionController.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/26.
//

import UIKit
import IGListKit

class ListSpacerSectionController: ListGenericSectionController<ListSpacer> {
    override func sizeForItem(at index: Int) -> CGSize {
        managedCellSize(of: ListSpacerCell.self, for: object)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        dequeueReusableCell(of: ListSpacerCell.self, at: index)
    }
}
