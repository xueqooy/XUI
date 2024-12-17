//
//  BindingListBuilder.swift
//  XUI
//
//  Created by xueqooy on 2024/1/25.
//

import UIKit
import IGListKit

/**
 Used for quickly building data-driven binding list

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

 class ViewModel: ListDiffable, ListCellSizeCacheIdentifiable {
     let valueText: String
     
     private let object: Object
     
     init(object: Object) {
         self.object = object
         self.valueText = "Item \(object.value)"
     }
     
     func diffIdentifier() -> NSObjectProtocol {
         object.diffIdentifier()
     }
     
     func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
         guard let object = object as? ViewModel else { return false }
         
         return object.valueText == valueText
     }
 }

 
 class Cell: UICollectionViewCell, ListBindable, ListCellSizeProviding {
     
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
     
     func bindViewModel(_ viewModel: Any) {
         guard let viewModel = viewModel as? ViewModel else {
             return
         }
         
         textLabel.text = viewModel.valueText
     }
 }
 
 class ViewController: UIViewController {
     
     private var objects: [Object] = (0..<50).map { Object(value: $0) }
     
     private let listConfiguration = BindingListBuilder.Configuration { sectionContext in
         [ViewModel(object: sectionContext.object as! Object)]
         
     } cellTypeProvider: { index, sectionContext in
         Cell.self
         
     } cellSizeProvider: { index, sectionContext in
         .XUI.automaticDimension
         
     } sectionStyleProvider: { object in
         .init(
             inset: .init(uniformValue: .XUI.spacing2),
             backgroundConfiguration: .overlay()
         )
     }

     private lazy var listBuilder = BindingListBuilder(objects: objects, configuration: listConfiguration)
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         view.backgroundColor = .white
         
         listBuilder.addList(to: self)
     }
 }

```
 */
final public class BindingListBuilder: NSObject, ListBuilder {
    
    public typealias ViewModel = ListDiffable
    public typealias BindingCell = Cell & ListBindable
    
    public typealias AutomaticDimensionViewModel = ListCellSizeCacheIdentifiable & ViewModel
    public typealias AutomaticDimensionBindingCell = ListCellSizeProviding & BindingCell
    
    public typealias ViewModelProvider = (_ sectionContext: BindingListSectionContext) -> [ViewModel]
    public typealias BindingCellTypeProvider = (_ index: Int, _ sectionContext: BindingListSectionContext) -> BindingCell.Type
    public typealias BindingCellSizeProvider = (_ index: Int, _ sectionContext: BindingListSectionContext) -> CGSize
    
    public typealias ItemSelectHandler = (_ index: Int, _ sectionContext: BindingListSectionContext) -> Void
    

    public struct Configuration {
        
        public let scrollDirection: UICollectionView.ScrollDirection
        public let viewModelProvider: ViewModelProvider
        public let cellTypeProvider: BindingCellTypeProvider
        public let cellSizeProvider: BindingCellSizeProvider?
        public let sectionStyleProvider: SectionStyleProvider?
        public let itemDidSelectHandler: ItemSelectHandler?
        public let itemDidDeselectHandler: ItemSelectHandler?
        
        /// Provide comprehensive list configuration providers
        /// - Parameters:
        ///   - objects: Top level object of driver list
        ///   - viewModelProvider: Provide an array of view models for object mapping
        ///   - cellTypeProvider: Provide Cell type based on the view model
        ///   - cellSizeProvider: Provide cell size based on the view model
        ///   - sectionStyleProvider: Provide Section configuration, including Inset and background settings, etc
        ///   - itemDidSelectHandler: handle item selection
        ///
        /// - Note:
        ///   The `cellSizeProvider` can be passed as nil or return `.XUI.automaticDimension` within the block. This requires the cell to conform to the `ListCellSizeProviding` protocol, and the `ViewModel` to conform to the `ListCellSizeCacheIdentifiable` protocol. The former provides the size of the cell, while the latter supplies the cache identifier for the cell size.
        ///
        public init(
            scrollDirection: UICollectionView.ScrollDirection = .vertical,
            viewModelProvider: @escaping ViewModelProvider,
            cellTypeProvider: @escaping BindingCellTypeProvider,
            cellSizeProvider: BindingCellSizeProvider? = nil,
            sectionStyleProvider: SectionStyleProvider? = nil,
            itemDidSelectHandler: ItemSelectHandler? = nil,
            itemDidDeselectHandler: ItemSelectHandler? = nil
        ) {
            self.scrollDirection = scrollDirection
            self.viewModelProvider = viewModelProvider
            self.cellTypeProvider = cellTypeProvider
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
            
            return _BindingSectionController(selectionDelegate: self, dataSource: self, sectionStyle: configuration)
        }
        return listController
    }()
    
    public init(objects: [Object]? = nil, configuration: Configuration) {
        self.configuration = configuration
        
        super.init()
        
        if let objects {
            Task { @MainActor in
                listController.objects = objects
            }
        }
    }
}


// MARK: - ListBindingSectionControllerDataSource

extension BindingListBuilder: ListBindingSectionControllerDataSource {
    
    public func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        
        let sectionContext = (sectionController as! _BindingSectionController).context
        return configuration.viewModelProvider(sectionContext)
    }
    
    public func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        
        let sectionContext = (sectionController as! _BindingSectionController).context
        let cellType = configuration.cellTypeProvider(index, sectionContext)
        
        return sectionController.collectionContext.dequeueReusableCell(of: cellType, for: sectionController, at: index) as! BindingCell
    }
    
    public func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        
        let sectionContext = (sectionController as! _BindingSectionController).context
 
        if let cellSizeProvider = configuration.cellSizeProvider {
            let cellSize = cellSizeProvider(index, sectionContext)
            
            if cellSize != .XUI.automaticDimension {
                return  cellSize
            }
        }
        
        // Use automatic dimension size
        let cellType = configuration.cellTypeProvider(index, sectionContext)

        precondition(cellType is AutomaticDimensionBindingCell.Type, "Automatic dimension requires the Cell conforms to ListCellSizeProviding")
        precondition(type(of: viewModel) is AutomaticDimensionViewModel.Type, "Automatic dimension requires the ViewModel conforms to ListCellSizeCacheIdentifiable")
        
        let automaticDimensionCellType = cellType as! AutomaticDimensionBindingCell.Type
        let automaticDimensionViewModel = viewModel as! AutomaticDimensionViewModel

        return sectionController.managedCellSize(of: automaticDimensionCellType, for: automaticDimensionViewModel)
    }
}


extension BindingListBuilder: ListBindingSectionControllerSelectionDelegate {
    
    public func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didSelectItemAt index: Int, viewModel: Any) {
        let sectionContext = (sectionController as! _BindingSectionController).context

        configuration.itemDidSelectHandler?(index, sectionContext)
    }
    
    public func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didDeselectItemAt index: Int, viewModel: Any) {
        let sectionContext = (sectionController as! _BindingSectionController).context

        configuration.itemDidDeselectHandler?(index, sectionContext)
    }
    
    public func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didHighlightItemAt index: Int, viewModel: Any) {
        
    }
    
    public func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didUnhighlightItemAt index: Int, viewModel: Any) {
        
    }
    
    
}
