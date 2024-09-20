//
//  ListCellSizeManager.swift
//  LLPUI
//
//  Created by xueqooy on 2023/7/28.
//

import UIKit
import IGListKit
import LLPUtils

class ListCellSizeManager<Cell : UICollectionViewCell & ListCellSizeProviding> {
    
    private struct Key: Hashable {
        let id: NSObjectProtocol
        let layoutContext: ListCellLayoutContext
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id.hash)
            hasher.combine(layoutContext)
        }
        
        static func == (lhs: ListCellSizeManager<Cell>.Key, rhs: ListCellSizeManager<Cell>.Key) -> Bool {
            lhs.id.isEqual(rhs.id) && lhs.layoutContext == rhs.layoutContext
        }
    }
    
    private var cache = [Key : CGSize]()
    
    private lazy var dummyCell: Cell = {
        let cell = Cell.init()
        // Mark the cell as dummy, then we can determine whether resources need to be configured for the cell
        cell.markAsDummy()
        return cell
    }()

    func size<Object: ListCellSizeCacheIdentifiable>(for object: Object, layoutContext: ListCellLayoutContext, configureCell: (Cell, Object) -> Void) -> CGSize {
        dummyCell.layoutContext = layoutContext
        

        let cellSizeOptions = dummyCell.cellSizeOptions
        
        let shouldCache = cellSizeOptions.contains(.cache)
        lazy var key = Key(id: object.cellSizeCacheId, layoutContext: layoutContext)
        if shouldCache {
            // Return if hit the cache
            if let hit = cache[key] {
                return hit
            }
        }
                
            
        if cellSizeOptions.contains(.configureCell) {
            // Configure cell before calculating
            configureCell(dummyCell, object)
        }
        
        let size = calculateCellSize(for: dummyCell)
        
        
        if shouldCache {
            cache[key] = size
        }
        
        return size
    }
    
    func size(for viewModel: ListCellSizeCacheIdentifiable, layoutContext: ListCellLayoutContext) -> CGSize where Cell : ListBindable {
        size(for: viewModel, layoutContext: layoutContext) { cell, viewModel in
            cell.bindViewModel(viewModel)
        }
    }
    
    func invalidateSize(forCacheId id: NSObjectProtocol, layoutContext: ListCellLayoutContext) {
        let key = Key(id: id, layoutContext: layoutContext)
        cache[key] = nil
    }
    
    private func calculateCellSize(for cell: Cell) -> CGSize {
        // When the size is autodimension, we need to consider whether it should be compressed
        // If compression is not required, the extent of cell‘s scrolling cross axis is always the same as the extent of the section container
        // If compression is required, the extent of cell‘s scrolling cross axis will be as small as possible, but will not exceed the extent of the section container.
        
        let autoDimensionSize: CGSize = .LLPUI.automaticDimension
        var cellSize = cell.cellSize
        let layoutContext = cell.layoutContext
        let isHorizontal = layoutContext.scrollDirection == .horizontal
        
        // Make sure the cell extent of the scroll cross axis is no greater than sectionScrollCrossAxisExtent
        if isHorizontal {
            cellSize.height = min(layoutContext.sectionScrollCrossAxisExtent, cellSize.height)
        } else {
            cellSize.width = min(layoutContext.sectionScrollCrossAxisExtent, cellSize.width)
        }
        
        switch cellSize {
        case autoDimensionSize:
            // Auto dimension for width and height
            let shouldCompress = cell.cellSizeOptions.contains(.compress)
            
            if isHorizontal {
                if shouldCompress {
                    let cellSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                    
                    if cellSize.height <= layoutContext.sectionScrollCrossAxisExtent {
                        return cellSize
                    }
                }
                
                return cell.contentView.systemLayoutSizeFitting(CGSize(width: 0, height: layoutContext.sectionScrollCrossAxisExtent), withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
                
            } else {
                if shouldCompress {
                    let cellSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                    
                    if cellSize.width <= layoutContext.sectionScrollCrossAxisExtent {
                        return cellSize
                    }
                }
                
                return cell.contentView.systemLayoutSizeFitting(CGSize(width: layoutContext.sectionScrollCrossAxisExtent, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            }
         
        case let cellSize where cellSize.width == autoDimensionSize.width:
            // Auto dimension for width
            let shouldCompress = cell.cellSizeOptions.contains(.compress)
           
            if isHorizontal {
                return cell.contentView.systemLayoutSizeFitting(CGSize(width: 0, height: cellSize.height), withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
                
            } else {
                if shouldCompress {
                    let cellSize = cell.contentView.systemLayoutSizeFitting(CGSize(width: 0, height: cellSize.height), withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
                    
                    if cellSize.width <= layoutContext.sectionScrollCrossAxisExtent {
                        return cellSize
                    }
                }
                
                return layoutContext.stretchedSize(withScrollAxisExtent: cellSize.height)
            }
            
        case let cellSize where cellSize.height == autoDimensionSize.height:
            // Auto dimension for height
            let shouldCompress = cell.cellSizeOptions.contains(.compress)
           
            if isHorizontal {
                if shouldCompress {
                    let cellSize = cell.contentView.systemLayoutSizeFitting(CGSize(width: cellSize.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
                    
                    if cellSize.height <= layoutContext.sectionScrollCrossAxisExtent {
                        return cellSize
                    }
                }
                
                return layoutContext.stretchedSize(withScrollAxisExtent: cellSize.width)
                
            } else {
                return cell.contentView.systemLayoutSizeFitting(CGSize(width: cellSize.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            }
            
        default:
            return cellSize
        }
    }
}

