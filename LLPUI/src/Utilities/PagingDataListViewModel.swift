//
//  PagingDataListViewModel.swift
//  pangaea
//
//  Created by xueqooy on 2024/1/5.
//  Copyright © 2024 Edmodo. All rights reserved.
//

import Foundation
import LLPUtils
import Combine
import IGListDiffKit

open class PagingDataListViewModel<DataProvider: PagingDataProviding> {
    
    public var cancellables = Set<AnyCancellable>()
    
    public private(set) var dataManager: PagingDataManager<DataProvider>!
         
    private let debounceToUpdateObjectsSubject = PassthroughSubject<Void, Never>()
    
    private var updateObjectsCancellable: AnyCancellable?
    
    private var dataManagerBoundCancellables = Set<AnyCancellable>()
    
    @State
    private var objects: [ListDiffable] = []
    
    @State
    public private(set) var loadStatus: BindingListLoadStatus = .idle
    
    @EquatableState
    private var canLoadMore: Bool = false
    
    public init() {
        // Avoid frequent update calls
        updateObjectsCancellable = debounceToUpdateObjectsSubject
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateObjects()
            }
        
        remakeDataManager()
    }

    
    public func remakeDataManager() {
        let dataManager = makeDataManager()
        
        if let previousDataManager = self.dataManager, dataManager === previousDataManager {
            return
        }
        
        self.dataManager = dataManager
        
        dataManagerBoundCancellables.removeAll()
        
        dataManager.$data.didChange
            .sink { [weak self] _ in
                guard let self = self else { return }
                                
                self.requestToUpdateObjects(immediately: self.objects.isEmpty)
            }
            .store(in: &dataManagerBoundCancellables)
        
        dataManager.$status.didChange
            .sink { [weak self] in
                guard let self else { return
                }
                switch $0 {
                case .idle:
                    if !self.loadStatus.isIdle {
                        self.loadStatus = .idle
                    }
                    
                case .loading:
                    if !self.loadStatus.isLoading {
                        self.loadStatus = .loading
                    }
                    
                case .success:
                    if !self.loadStatus.isSuccess {
                        self.loadStatus = .success
                    }
                    
                case .failure(let error):
                    self.loadStatus = .failure(error)
                }
            }
            .store(in: &dataManagerBoundCancellables)
        
        dataManager.$canLoadMore.didChange
            .assign(to: \.canLoadMore, on: self, ownership: .weak)
            .store(in: &dataManagerBoundCancellables)
    }
    
    
    public func requestToUpdateObjects(immediately: Bool = false) {
        if immediately {
            updateObjects()
        } else {
            debounceToUpdateObjectsSubject.send(())
        }
    }
    
    private func updateObjects() {
        objects = makeObjects()
    }
    
    // MARK: - Subclass Overrides
    
    open func makeDataManager() -> PagingDataManager<DataProvider> {
        fatalError("Suclass should override this method")
    }
    
    open func dataWillReload() {
    }
    
    open func makeObjects() -> [ListDiffable] {
        fatalError("Suclass should override this method")
    }
}

extension PagingDataListViewModel: BindingListViewModel {
    public var objectsPublisher: AnyPublisher<[ListDiffable], Never> {
        $objects.didChange
    }
    
    public var loadStatusPublisher: AnyPublisher<BindingListLoadStatus, Never>? {
        $loadStatus.didChange
    }
    
    public var canLoadMorePublisher: AnyPublisher<Bool, Never>? {
        $canLoadMore.didChange
    }

    public func reloadData() {
        dataWillReload()
        
        dataManager.loadData()
    }
    
    public func loadMoreData() {
        dataManager.loadData(action: .loadMore)
    }
}
