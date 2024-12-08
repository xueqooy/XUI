//
//  ListBuilderPrivate.swift
//  XUI
//
//  Created by xueqooy on 2024/1/25.
//

import Foundation
import IGListKit
import Combine
import XKit

// MARK: - _ListController

final class _ListController: ListController {
    
    override var sectionControllerProvider: ListController.SectionControllerProvider? {
        willSet {
            if sectionControllerProvider != nil {
                preconditionFailure("sectionControllerProvider of _BindingListController can‘t be modified")
            }
        }
    }
    
    init(scrollDirection: UICollectionView.ScrollDirection = .vertical, sectionControllerProvider: @escaping SectionControllerProvider) {
        super.init(scrollDirection: scrollDirection)
        
        self.sectionControllerProvider = sectionControllerProvider
    }
}


// MARK: - _PrivateSectionControllerProtocol

protocol _PrivateSectionControllerProtocol: ListSectionBackgroundConfigurationProviding where Self : ListSectionController {
    
    associatedtype Object
    associatedtype SectionContext
    
    var cancellables: Set<AnyCancellable> { set get }
    
    var sectionStyle: ListSectionStyle { get }
    
    var object: Object { get }
            
    var context: SectionContext { get }
}

private let cancellablesAssociation = Association<Set<AnyCancellable>>(wrap: .retain)


extension _PrivateSectionControllerProtocol {
    
    var cancellables: Set<AnyCancellable> {
        get {
            if let cancellables = cancellablesAssociation[self] {
                return cancellables
            }
            
            let cancellables = Set<AnyCancellable>()
            cancellablesAssociation[self] = cancellables
            return cancellables
        }
        set {
            cancellablesAssociation[self] = newValue
        }
    }
    

    // ListSectionBackgroundConfigurationProviding
    
    var sectionBackgroundInset: Insets {
        sectionStyle.backgroundInset
    }
    
    var sectionBackgroundConfiguration: BackgroundConfiguration? {
        sectionStyle.backgroundConfiguration
    }

}


// MARK: - _GenericSectionController

protocol _GenericSectionControllerDelegate: AnyObject {
    
    func sectionController(_ sectionController: _GenericSectionController, didSelectItemAt index: Int)
    
    func sectionController(_ sectionController: _GenericSectionController, didDeselectItemAt index: Int)
}

protocol _GenericSectionControllerDataSource: AnyObject {
    
    func sectionController(_ sectionController: _GenericSectionController, numberOfItemsFor object: Any) -> Int
    
    func sectionController(_ sectionController: _GenericSectionController, sizeForItemAt index: Int) -> CGSize
    
    func sectionController(_ sectionController: _GenericSectionController, cellForItemAt index: Int) -> UICollectionViewCell
}

final class _GenericSectionController: ListSectionController, _PrivateSectionControllerProtocol {
    
    let sectionStyle: ListSectionStyle
    
    weak var delegate: _GenericSectionControllerDelegate?
    weak var dataSource: _GenericSectionControllerDataSource?
    
    var context: ListSectionContext {
        ListSectionContext(sectionController: self)
    }
    
    private(set) var object: Any?

    required init(delegate: _GenericSectionControllerDelegate, dataSource: _GenericSectionControllerDataSource, sectionStyle: ListSectionStyle) {
        
        self.sectionStyle = sectionStyle
        
        super.init()
        
        self.inset = sectionStyle.inset
        self.delegate = delegate
        self.dataSource = dataSource
    }
    
    override func didUpdate(to object: Any) {
        self.object = object
    }
    
    override func numberOfItems() -> Int {
        dataSource?.sectionController(self, numberOfItemsFor: self.object!) ?? 0
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        dataSource?.sectionController(self, sizeForItemAt: index) ?? .zero
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        dataSource?.sectionController(self, cellForItemAt: index) ?? .init()
    }
    
    override func didSelectItem(at index: Int) {
        delegate?.sectionController(self, didSelectItemAt: index)
    }
    
    override func didDeselectItem(at index: Int) {
        delegate?.sectionController(self, didDeselectItemAt: index)
    }
}


// MARK: - _BindingSectionController

final class _BindingSectionController: ListBindingSectionController<ListDiffable>, _PrivateSectionControllerProtocol {
            
    var context: BindingListSectionContext {
        BindingListSectionContext(sectionController: self)
    }
    
    let sectionStyle: ListSectionStyle
    
    init(selectionDelegate: ListBindingSectionControllerSelectionDelegate, dataSource: ListBindingSectionControllerDataSource, sectionStyle: ListSectionStyle) {
        
        self.sectionStyle = sectionStyle
        
        super.init()
        
        self.inset = sectionStyle.inset
        self.selectionDelegate = selectionDelegate
        self.dataSource = dataSource
    }
}


