//
//  ListController.swift
//  XUI
//
//  Created by xueqooy on 2023/8/10.
//

import Foundation
import IGListKit
import Combine

/// A controller that manages a list of objects and their corresponding section controllers.
/// Only for vertical list, not support horizontal list.
public class ListController: NSObject {
        
    public typealias Handler = (ListController) -> Void
    public typealias SectionControllerProvider = (ListDiffable) -> ListSectionController?
    
    public var sectionControllerProvider: SectionControllerProvider? {
        didSet {
            Task { @MainActor in
                // If both the controller‘s objects and currently driving the adapter are empty, there is no need to call reloadData()
                if listAdapter.objects().isEmpty && objects.isEmpty {
                    return
                }
                
                await reloadData()
            }
        }
    }
    
    @MainActor public var objects: [ListDiffable] = [] {
        didSet {
            guard !disablesUpdatesBySettingObjects else {
                return
            }
            
            listAdapter.performUpdates(animated: true)
        }
    }
    
    public private(set) lazy var listView: ListView = {
        let listView = ListView(scrollDirection: scrollDirection)
        
        listView.layout.sectionBackgroundConfigurationProvider = { [weak self] section in
            guard let self = self, let provider = self.listAdapter.sectionController(forSection: section) as? ListSectionBackgroundConfigurationProviding else {
                return nil
            }
        
            return provider
        }
        
        listView.layout.sectionInnerBackgroundConfigurationProvider = { [weak self] section in
            guard let self = self, let provider = self.listAdapter.sectionController(forSection: section) as? ListSectionInnerBackgroundConfigurationProviding else {
                return nil
            }
        
            return provider
        }
        
        listView.layout.sectionConnectionConfigurationProvider = { [weak self] section in
            guard let self = self, let provider = self.listAdapter.sectionController(forSection: section) as? ListSectionConnectionConfigurationProviding else {
                return nil
            }
        
            return provider
        }
        
        return listView
    }()
    
    
    @MainActor public var viewController: UIViewController? {
        set {
            listAdapter.viewController = newValue
            
            // Invalidate layout after orientation changed
            viewSizeTransitionCancellable = newValue?.viewWillTransitionToSizePublisher
                .sink(receiveValue: { [weak self] (size, coordinator) in
                    guard let self = self else {
                        return
                    }
                    
                    coordinator.animate { _ in
                        self.listView.layout.invalidateLayout()
                    }
                })
        }
        get {
            listAdapter.viewController
        }
    }
    
    @MainActor public var emptyView: UIView? {
        didSet {
            if objects.isEmpty {
                listAdapter.reloadData()
            }
        }
    }
    
    public let scrollDirection: UICollectionView.ScrollDirection
            
    internal lazy var listAdapter: ListAdapter = {
        let listAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
        listAdapter.collectionView = listView
        listAdapter.scrollViewDelegate = self
        listAdapter.moveDelegate = self
        listAdapter.dataSource = self
        return listAdapter
    }()
            
    private lazy var loadMoreSpinner = ListSpinner(identifier: "ListController.LoadMore")
    
    private var viewSizeTransitionCancellable: AnyCancellable?
    
    private var disablesUpdatesBySettingObjects: Bool = false
        
    public init(scrollDirection: UICollectionView.ScrollDirection = .vertical) {
        self.scrollDirection = scrollDirection
    }
    
    @discardableResult
    @MainActor public func updateObjects(_ objects: [ListDiffable], animated: Bool = true) async -> Bool {
        disablesUpdatesBySettingObjects = true
        self.objects = objects
        disablesUpdatesBySettingObjects = false
        
        return await listAdapter.performUpdates(animated: animated)
    }
    
    @discardableResult
    @MainActor public func appendObjects(_ objects: [ListDiffable], animated: Bool = true) async -> Bool {
        var updatedObjects = self.objects
        updatedObjects.append(contentsOf: objects)
        
        return await updateObjects(updatedObjects, animated: animated)
    }
    
    @discardableResult
    @MainActor public func reloadData() async -> Bool {
        await listAdapter.reloadData()
    }

    @MainActor public func scrollToObject(_ object: ListDiffable, animated: Bool = true) {
        listAdapter.scroll(to: object, supplementaryKinds: nil, scrollDirection: .vertical, scrollPosition: .centeredVertically, additionalOffset: 0, animated: animated)
    }
}

extension ListController: ListAdapterDataSource {
    @MainActor public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result = objects
        
        if isLoadingMore {
            result.append(loadMoreSpinner)
        }
        
        return result
    }
    
    @MainActor public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        emptyView
    }
    
    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is ListSpinner:
            return ListSpinnerSectionController()
            
        case is ListSpacer:
            return ListSpacerSectionController()
            
        case is ListToastObject:
            return ListToastSectionController()
            
        case is ListEmptyObject:
            return ListEmptySectionController()
            
        default:
            return sectionControllerProvider?(object as! ListDiffable) ?? ListSingleSectionController(cellClass: UICollectionViewCell.self, configureBlock: { _, _ in }, sizeBlock: { _, _ in .zero })
        }
    }
}

extension ListController: ListAdapterMoveDelegate {
    @MainActor public func listAdapter(_ listAdapter: ListAdapter, move object: Any, from previousObjects: [Any], to objects: [Any]) {
        self.objects = objects as! [ListDiffable]
    }
}

