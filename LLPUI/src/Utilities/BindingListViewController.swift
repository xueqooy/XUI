//
//  BindingListViewController.swift
//  LLPUI
//
//  Created by xueqooy on 2024/10/19.
//

import UIKit
import LLPUtils
import IGListKit
import IGListDiffKit
import Combine

open class BindingListViewController<ViewModel: BindingListViewModel>: BindingViewController<ViewModel> {
    
    public let listController = ListController().then {
        $0.canRefresh = true
    }
    
    private var emptyView: EmptyView?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.background1

        listController.viewController = self
        
        listController.sectionControllerProvider = { [weak self] object in
            guard let self = self else {
                return nil
            }
            
            return self.sectionController(for: object)
        }
        
        reloadEmptyView()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if shouldReloadEmptyViewWhenViewSizeChanged {
            reloadEmptyView()
        }
    }
    
    open func reloadEmptyView() {
        if let emptyConfiguration = makeEmptyConfiguration() {
            emptyView = EmptyView(configuration: emptyConfiguration)
        } else {
            emptyView = nil
        }
        
        listController.emptyView = emptyView
        
        updateLoadingStateOfEmptyView()
    }
    
    private func updateLoadingStateOfEmptyView() {
        guard let emptyView else { return }
                
        emptyView.configuration.isLoading = switch viewModel.loadStatus {
        case .loading:
            true
            
        case .success:
            // Keep loading to avoid briefly displaying empty view after loading data
            !self.listController.objects.isEmpty
            
        default:
            false
        }
    }
        
    // MARK: - Subclass Overrides
    
    open var shouldReloadEmptyViewWhenViewSizeChanged: Bool {
        true
    }
    
    /// Super required
    open override func setupUI() {
        view.addSubview(listController.listView)
        listController.listView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// Super required
    open override func performBinding() {
        // Initial data loading
        viewStatePublisher
            .filter { $0 == .isAppearing }
            .first()
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.viewModel.reloadData()
            }
            .store(in: &cancellables)
        
        listController.refreshHandler = { [weak self] _ in
            guard let self = self else { return }
            
            self.viewModel.reloadData()
        }
        
        listController.loadMoreHandler = { [weak self] _ in
            guard let self = self else { return }
            
            self.viewModel.loadMoreData()
        }
        
        viewModel.objectsPublisher
            .handleEvents(receiveOutput: { [weak self] objects in
                guard let self = self else {
                    return
                }
                
                // Ensure empty view is displaying when data is empty and not in loading
                if objects.isEmpty && !self.viewModel.loadStatus.isLoading {
                    self.emptyView?.configuration.isLoading = false
                }
            })
            .assign(to: \.objects, on: listController)
            .store(in: &cancellables)
        
        viewModel.loadStatusPublisher?
            .sink { [weak self] status in
                guard let self else { return }
                
                if !status.isLoading {
                    self.listController.endRefreshing()
                    self.listController.endLoadingMore()
                    
                    self.reloadEmptyView()
                }
                
                self.updateLoadingStateOfEmptyView()
            }
            .store(in: &cancellables)
       
        viewModel.canLoadMorePublisher?
            .assign(to: \.canLoadMore, on: listController)
            .store(in: &cancellables)
    }
    
    
    open func sectionController(for object: ListDiffable) -> ListSectionController? {
        nil
    }
    
    open func makeEmptyConfiguration() -> EmptyConfiguration? {
        nil
    }
}
