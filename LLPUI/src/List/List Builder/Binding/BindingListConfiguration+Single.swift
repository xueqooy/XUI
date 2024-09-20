//
//  BindingListConfiguration+Single.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/26.
//

import UIKit
import IGListDiffKit

public extension BindingListBuilder.Configuration {
    
    static func single<Cell: BindingListBuilder.BindingCell>(
        of _: Cell.Type,
        scrollDirection: UICollectionView.ScrollDirection = .vertical,
        viewModelProvider: @escaping (_ sectionContext: ListSectionContext) -> BindingListBuilder.ViewModel,
        cellSizeProvider: ((_ sectionContext: ListSectionContext) -> CGSize)? = nil,
        sectionStyleProvider: ListBuilder.SectionStyleProvider? = nil,
        itemDidSelectHandler: ((_ sectionContext: ListSectionContext) -> Void)? = nil, itemDidDeselectHandler: ((_ sectionContext: ListSectionContext) -> Void)? = nil) -> Self {
            
            .init(scrollDirection: scrollDirection, viewModelProvider: { sectionContext in
                [viewModelProvider(sectionContext)]
                
            }, cellTypeProvider: { index, sectionContext in
                Cell.self
                
            }, cellSizeProvider: { index, sectionContext in
                cellSizeProvider?(sectionContext) ?? .LLPUI.automaticDimension
                
            }, sectionStyleProvider: sectionStyleProvider, itemDidSelectHandler: { index, sectionContext in
                itemDidSelectHandler?(sectionContext)
                
            }, itemDidDeselectHandler: { index, sectionContext in
                itemDidDeselectHandler?(sectionContext)
            })

    }
}
