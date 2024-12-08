//
//  ListSectionController+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2023/9/14.
//

import IGListKit
import XKit

public extension ListSectionController {
    
    var sectionContainerWidth: CGFloat {
        collectionContext.insetContainerSize.width - inset.horizontal
    }
    
    var sectionContainerHeight: CGFloat {
        collectionContext.insetContainerSize.height - inset.vertical
    }
    
    
    // MARK: - The following properties and methods are only valid when using ListView
    
    /// The scroll direction
    /// - warning: only valid when using `ListView`
    var scrollDirection: UICollectionView.ScrollDirection {
        #if DEBUG
        Asserts.failure("Only valid when using ListController", condition: (collectionContext as? ListAdapter)?.collectionView as? ListView != nil)
        #endif
        
        return ((collectionContext as! ListAdapter).collectionView as! ListView).layout.scrollDirection
    }
    
    /// Section container width for vertical scroll direction, or height for horizontal scroll direction.
    /// - warning: only valid when using `ListView`
    var scrollCrossAxisExtent: CGFloat {
        scrollDirection == .vertical ? sectionContainerWidth : sectionContainerHeight
    }
     
    /// The layout context of the cell
    /// - warning: only valid when using `ListView`
    var cellLayoutContext: ListCellLayoutContext {
        .init(scrollDirection: scrollDirection, sectionScrollCrossAxisExtent: scrollCrossAxisExtent)
    }
    
    /// Dequeue a cell of the specified type, and assign the layout context to the cell if it conforms to `ListCellSizeProviding`
    /// - warning: only valid when using `ListView`
    func dequeueReusableCell<T: UICollectionViewCell>(of _: T.Type, at index: Int) -> T {
        guard let cell = collectionContext.dequeueReusableCell(
            of: T.self,
            for: self,
            at: index
        ) as? T else {
            fatalError()
        }
        
        if let cellSizeProvider = cell as? ListCellSizeProviding {
            cellSizeProvider.layoutContext = cellLayoutContext
        }

        return cell
    }
    
    /// Get the managed cell size for the specified cell type and view model
    /// - warning: only valid when using `ListView`
    func managedCellSize<Cell: UICollectionViewCell & ListCellSizeProviding & ListBindable>(of _: Cell.Type, for viewModel: ListCellSizeCacheIdentifiable) -> CGSize {
        collectionContext.cellSizeManager(of: Cell.self).size(for: viewModel, layoutContext: cellLayoutContext)
    }
    
    /// Get the managed cell size for the specified cell type, object and configure block
    /// - warning: only valid when using `ListView`
    func managedCellSize<Cell: UICollectionViewCell & ListCellSizeProviding, Object: ListCellSizeCacheIdentifiable>(of _: Cell.Type, for object: Object, configureCell: (Cell, Object) -> Void) -> CGSize {
        collectionContext.cellSizeManager(of: Cell.self).size(for: object, layoutContext: cellLayoutContext, configureCell: configureCell)
    }
    
    /// Invalidate the cell size for the specified cell type and cache id
    /// - warning: only valid when using `ListView`
    func invalidateCellSize<Cell: UICollectionViewCell & ListCellSizeProviding>(of _: Cell.Type, forCacheId id: NSObjectProtocol) {
        collectionContext.cellSizeManager(of: Cell.self).invalidateSize(forCacheId: id, layoutContext: cellLayoutContext)
    }
}
