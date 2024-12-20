//
//  PagingDataListViewModel.swift
//  pangaea
//
//  Created by xueqooy on 2024/1/5.
//  Copyright © 2024 Edmodo. All rights reserved.
//

import Combine
import Foundation
import IGListDiffKit
import XKit

open class PagingDataListViewModel<DataProvider: PagingDataProviding>: BindingListViewModel {
    public private(set) var dataManager: PagingDataManager<DataProvider>!

    override public var canLoadMorePublisher: AnyPublisher<Bool, Never>? {
        $canLoadMore.didChange
    }

    private let debounceToUpdateObjectsSubject = PassthroughSubject<Void, Never>()

    private var updateObjectsCancellable: AnyCancellable?

    private var dataManagerBoundCancellables = Set<AnyCancellable>()

    @EquatableState
    private var canLoadMore: Bool = false

    override public init() {
        super.init()

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

                case let .failure(error):
                    self.loadStatus = .failure(error)
                }
            }
            .store(in: &dataManagerBoundCancellables)

        dataManager.$canLoadMore.didChange
            .sink { [weak self] in
                guard let self else { return }

                self.canLoadMore = $0
            }
            .store(in: &dataManagerBoundCancellables)
    }

    public func requestToUpdateObjects(immediately: Bool = false) {
        if immediately {
            updateObjects()
        } else {
            debounceToUpdateObjectsSubject.send(())
        }
    }

    override public func loadData() {
        dataWillReload()

        dataManager.loadData()
    }

    override public func loadMoreData() {
        dataManager.loadData(action: .loadMore)
    }

    private func updateObjects() {
        objects = makeObjects()
    }

    // MARK: - Subclass Overrides

    open func makeDataManager() -> PagingDataManager<DataProvider> {
        fatalError("Suclass should override this method")
    }

    open func dataWillReload() {}

    open func makeObjects() -> [ListDiffable] {
        fatalError("Suclass should override this method")
    }
}
