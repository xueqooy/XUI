//
//  GenericListConfiguration+Single.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/26.
//

import UIKit
import IGListDiffKit

public extension GenericListBuilder.Configuration {
    
    static func single<Cell: ListBuilder.Cell>(
        of _: Cell.Type,
        scrollDirection: UICollectionView.ScrollDirection = .vertical,
        cellConfigurator: @escaping (_ cell: Cell, _ sectionContext: ListSectionContext) -> Void,
        cellSizeProvider: ((_ sectionContext: ListSectionContext) -> CGSize)? = nil,
        sectionStyleProvider: ListBuilder.SectionStyleProvider? = nil,
        itemDidSelectHandler: ((_ sectionContext: ListSectionContext) -> Void)? = nil,
        itemDidDeselectHandler: ((_ sectionContext: ListSectionContext) -> Void)? = nil) -> Self {
            
        .init(scrollDirection: scrollDirection, cellTypeProvider: { index, sectionContext in
            Cell.self
            
        }, cellConfigurator: { cell, index, sectionContext in
            cellConfigurator(cell as! Cell, sectionContext)
            
        }, itemCountProvider: { sectionContext in
            1
            
        }, cellSizeProvider: { index, sectionContext in
            cellSizeProvider?(sectionContext) ?? .LLPUI.automaticDimension
            
        }, sectionStyleProvider: sectionStyleProvider, itemDidSelectHandler: { index, sectionContext in
            itemDidSelectHandler?(sectionContext)
            
        }, itemDidDeselectHandler: { index, sectionContext in
            itemDidDeselectHandler?(sectionContext)
        })
    }
    
}
