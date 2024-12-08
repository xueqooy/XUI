//
//  ListSpinnerSectionController.swift
//  XUI
//
//  Created by xueqooy on 2023/8/10.
//

import UIKit
import IGListKit

class ListSpinnerSectionController: ListGenericSectionController<ListSpinner> {
    override func sizeForItem(at index: Int) -> CGSize {
        managedCellSize(of: ListSpinnerCell.self, for: object)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = dequeueReusableCell(of: ListSpinnerCell.self, at: index)
        cell.startAnimating()
        
        return cell
    }
}
