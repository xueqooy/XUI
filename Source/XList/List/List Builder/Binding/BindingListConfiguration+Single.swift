//
//  BindingListConfiguration+Single.swift
//  XUI
//
//  Created by xueqooy on 2024/1/26.
//

import IGListDiffKit
import UIKit

public extension BindingListBuilder.Configuration {
    static func single<Cell: BindingListBuilder.BindingCell>(
        of _: Cell.Type,
        scrollDirection: UICollectionView.ScrollDirection = .vertical,
        viewModelProvider: @escaping (_ sectionContext: ListSectionContext) -> BindingListBuilder.ViewModel,
        cellSizeProvider: ((_ sectionContext: ListSectionContext) -> CGSize)? = nil,
        sectionStyleProvider: ListBuilder.SectionStyleProvider? = nil,
        itemDidSelectHandler: ((_ sectionContext: ListSectionContext) -> Void)? = nil, itemDidDeselectHandler: ((_ sectionContext: ListSectionContext) -> Void)? = nil
    ) -> Self {
        .init(scrollDirection: scrollDirection, viewModelProvider: { sectionContext in
            [viewModelProvider(sectionContext)]

        }, cellTypeProvider: { _, _ in
            Cell.self

        }, cellSizeProvider: { _, sectionContext in
            cellSizeProvider?(sectionContext) ?? .XUI.automaticDimension

        }, sectionStyleProvider: sectionStyleProvider, itemDidSelectHandler: { _, sectionContext in
            itemDidSelectHandler?(sectionContext)

        }, itemDidDeselectHandler: { _, sectionContext in
            itemDidDeselectHandler?(sectionContext)
        })
    }
}
