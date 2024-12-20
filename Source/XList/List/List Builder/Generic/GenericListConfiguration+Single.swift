//
//  GenericListConfiguration+Single.swift
//  XUI
//
//  Created by xueqooy on 2024/1/26.
//

import IGListDiffKit
import UIKit

public extension GenericListBuilder.Configuration {
    static func single<Cell: ListBuilder.Cell>(
        of _: Cell.Type,
        scrollDirection: UICollectionView.ScrollDirection = .vertical,
        cellConfigurator: @escaping (_ cell: Cell, _ sectionContext: ListSectionContext) -> Void,
        cellSizeProvider: ((_ sectionContext: ListSectionContext) -> CGSize)? = nil,
        sectionStyleProvider: ListBuilder.SectionStyleProvider? = nil,
        itemDidSelectHandler: ((_ sectionContext: ListSectionContext) -> Void)? = nil,
        itemDidDeselectHandler: ((_ sectionContext: ListSectionContext) -> Void)? = nil
    ) -> Self {
        .init(scrollDirection: scrollDirection, cellTypeProvider: { _, _ in
            Cell.self

        }, cellConfigurator: { cell, _, sectionContext in
            cellConfigurator(cell as! Cell, sectionContext)

        }, itemCountProvider: { _ in
            1

        }, cellSizeProvider: { _, sectionContext in
            cellSizeProvider?(sectionContext) ?? .XUI.automaticDimension

        }, sectionStyleProvider: sectionStyleProvider, itemDidSelectHandler: { _, sectionContext in
            itemDidSelectHandler?(sectionContext)

        }, itemDidDeselectHandler: { _, sectionContext in
            itemDidDeselectHandler?(sectionContext)
        })
    }
}
