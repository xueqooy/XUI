//
//  MenuItemSectionController.swift
//  XUI
//
//  Created by xueqooy on 2024/4/29.
//

import IGListSwiftKit
import UIKit

class MenuItemSectionController: ListValueSectionController<TextSelectorMenuItem> {
    private let selectHandler: (TextSelectorMenuItem) -> Void

    init(selectHandler: @escaping (TextSelectorMenuItem) -> Void) {
        self.selectHandler = selectHandler
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = dequeueReusableCell(of: MenuItemCell.self, at: index)
        cell.title = value.title
        return cell
    }

    override func sizeForItem(at _: Int) -> CGSize {
        managedCellSize(of: MenuItemCell.self, for: value.title) { cell, title in
            cell.title = title
        }
    }

    override func didSelectItem(at _: Int) {
        selectHandler(value)
    }
}
