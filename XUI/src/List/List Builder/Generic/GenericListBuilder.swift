//
//  GenericListBuilder.swift
//  XUI
//
//  Created by xueqooy on 2024/1/25.
//

import UIKit
import IGListKit

/**
 Used for quickly building data-driven list
 
 Minimum Example
 
 ```
 class Object: ListDiffable, ListCellSizeCacheIdentifiable {
     let value: Int
     
     init(value: Int) {
         self.value = value
     }
     
     func diffIdentifier() -> NSObjectProtocol {
         value as NSObjectProtocol
     }
     
     func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
         true
     }
 }

 class Cell: UICollectionViewCell, ListCellSizeProviding {
     
     let textLabel = UILabel(textAlignment: .center)
     
     override init(frame: CGRect) {
         super.init(frame: frame)
         
         contentView.addSubview(textLabel)
         textLabel.snp.makeConstraints { make in
             make.edges.equalToSuperview().inset(UIEdgeInsets(uniformValue: .XUI.spacing5))
         }
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
 }
 
 class ViewController: UIViewController {
     
     private var objects: [Object] = (0..<50).map { Object(value: $0) }
     
     private let listConfiguration = GenericListBuilder.Configuration { object, index, sectionContext in
         Cell.self
         
     } cellConfigurator: { cell, index, sectionContext in
         let cell = cell as! Cell
         cell.textLabel.text = "Item: \((sectionContext.object as! Object).value)"
         
     } itemCountProvider: { sectionContext in
         1
         
     } cellSizeProvider: { index, sectionContext in
         .XUI.automaticDimension
         
     } sectionStyleProvider: { object in
         .init(
             inset: .init(uniformValue: .XUI.spacing2),
             backgroundConfiguration: .overlay()
         )
         
     }
     
     private lazy var listBuilder = GenericListBuilder(objects: objects, configuration: listConfiguration)
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         view.backgroundColor = .white
         
         listBuilder.addList(to: self)
     }
     
 }
```
 
 */

final public class GenericListBuilder: ListBuilder {
    
    public typealias AutoDimensionObject = Object & ListCellSizeCacheIdentifiable
    public typealias AutoDimensionCell = Cell & ListCellSizeProviding
    
    public typealias ItemCountProvider = (_ sectionContext: ListSectionContext) -> Int
    public typealias CellTypeProvider = (_ index: Int, _ sectionContext: ListSectionContext) -> Cell.Type
    public typealias CellConfigurator = (_ cell: Cell, _ index: Int, _ sectionContext: ListSectionContext) -> Void
    public typealias CellSizeProvider = (_ index: Int, _ sectionContext: ListSectionContext) -> CGSize
    public typealias ItemSelectHandler = (_ index: Int, _ sectionContext: ListSectionContext) -> Void

    
    public struct Configuration {
        
        public let scrollDirection: UICollectionView.ScrollDirection
        public let cellTypeProvider: CellTypeProvider
        public let cellConfigurator: CellConfigurator
        public let itemCountProvider: ItemCountProvider?
        public let cellSizeProvider: CellSizeProvider?
        public let sectionStyleProvider: SectionStyleProvider?
        public let itemDidSelectHandler: ItemSelectHandler?
        public let itemDidDeselectHandler: ItemSelectHandler?

        /// Provide comprehensive list configuration providers
        /// - Parameters:
        ///   - objects: Top level object of driver list
        ///   - cellTypeProvider: Provide cell type based on the view model
        ///   - cellConfigurator: Configure cell
        ///   - itemCountProvider: Provider number of items in section
        ///   - cellSizeProvider: Provider cell size for item
        ///   - sectionStyleProvider: Provide Section configuration, including Inset and background settings, etc
        ///
        /// - Note:
        ///   The `cellSizeProvider` can be passed as nil or return `.XUI.automaticDimension` within the block. This requires the cell to conform to the `ListCellSizeProviding` protocol, and the `Object` to conform to the `ListCellSizeCacheIdentifiable` protocol. The former provides the size of the cell, while the latter supplies the cache identifier for the cell size.
        ///
        public init(
            scrollDirection: UICollectionView.ScrollDirection = .vertical,
            cellTypeProvider: @escaping CellTypeProvider,
            cellConfigurator: @escaping CellConfigurator,
            itemCountProvider: ItemCountProvider? = nil,
            cellSizeProvider: CellSizeProvider? = nil,
            sectionStyleProvider: SectionStyleProvider? = nil,
            itemDidSelectHandler: ItemSelectHandler? = nil,
            itemDidDeselectHandler: ItemSelectHandler? = nil
        ) {
            self.scrollDirection = scrollDirection
            self.cellTypeProvider = cellTypeProvider
            self.cellConfigurator = cellConfigurator
            self.itemCountProvider = itemCountProvider
            self.cellSizeProvider = cellSizeProvider
            self.sectionStyleProvider = sectionStyleProvider
            self.itemDidSelectHandler = itemDidSelectHandler
            self.itemDidDeselectHandler = itemDidDeselectHandler
        }
    }
    
    public let configuration: Configuration
    
    public private(set) lazy var listController: ListController = {
        let listController = _ListController(scrollDirection: configuration.scrollDirection) { [weak self] object in
            guard let self else { return nil }
                        
            let configuration = self.configuration.sectionStyleProvider?(object) ?? .init()
            
            return _GenericSectionController(delegate: self, dataSource: self, sectionStyle: configuration)
        }
        return listController
    }()
    
    public init(objects: [Object]? = nil, configuration: Configuration) {
        self.configuration = configuration
                
        if let objects {
            Task { @MainActor in
                listController.objects = objects
            }
        }
    }    
}


// MARK: - _GenericSectionControllerDataSource

extension GenericListBuilder: _GenericSectionControllerDataSource {
    
    func sectionController(_ sectionController: _GenericSectionController, numberOfItemsFor object: Any) -> Int {
        configuration.itemCountProvider?(sectionController.context) ?? 1
    }
    
    func sectionController(_ sectionController: _GenericSectionController, sizeForItemAt index: Int) -> CGSize {
       
        let object = sectionController.object as! Object
        
        if let cellSizeProvider = configuration.cellSizeProvider {
            let cellSize = cellSizeProvider(index, sectionController.context)
            
            if cellSize != .XUI.automaticDimension {
                return  cellSize
            }
        }
        
        // Use automatic dimension size
        let cellType = configuration.cellTypeProvider(index, sectionController.context)
        
        precondition(cellType is AutoDimensionCell.Type, "Automatic dimension requires the Cell conforms to ListCellSizeProviding")
        precondition(type(of: object) is AutoDimensionObject.Type, "Automatic dimension requires the Object conforms to ListCellSizeCacheIdentifiable")
        
        let automaticDimensionCellType = cellType as! AutoDimensionCell.Type
        let automaticDimensionObject = object as! AutoDimensionObject
        
        return sectionController.managedCellSize(of: automaticDimensionCellType, for: automaticDimensionObject) { cell, object in
            self.configuration.cellConfigurator(cell, index, sectionController.context)
        }
    }
    
    func sectionController(_ sectionController: _GenericSectionController, cellForItemAt index: Int) -> UICollectionViewCell {
        let cellType = configuration.cellTypeProvider(index, sectionController.context)
        
        let cell = sectionController.collectionContext.dequeueReusableCell(of: cellType, for: sectionController, at: index)
        
        configuration.cellConfigurator(cell, index, sectionController.context)
        
        return cell
    }
}


// MARK: - _GenericSectionControllerDelegate

extension GenericListBuilder: _GenericSectionControllerDelegate {
    
    func sectionController(_ sectionController: _GenericSectionController, didSelectItemAt index: Int) {
        configuration.itemDidSelectHandler?(index, sectionController.context)
    }
    
    func sectionController(_ sectionController: _GenericSectionController, didDeselectItemAt index: Int) {
        configuration.itemDidDeselectHandler?(index, sectionController.context)
    }
    
}
