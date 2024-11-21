//
//  NestedScrollingViewController.swift
//  Pods
//
//  Created by xueqooy on 2024/11/20.
//

import UIKit

open class NestedScrollingViewController<ViewModel: GenericBindingViewModel>: GenericBindingViewController<ViewModel> {
        
    private lazy var nestedScrollingView: NestedScrollingView? = {
        if configuration.isRefreshEnabled || configuration.headerView != nil {
            NestedScrollingView(stickyHeader: configuration.stickyHeader).then {
                $0.automaticallyShowsHeader = true
                // Set it to never here, and the external safe area can be passed to the child interface (the parent scroll view may be set to automatic, which will cause the automatic behavior of the child scroll view to fail)
                $0.parent.contentInsetAdjustmentBehavior = .never
                $0.headerView = configuration.headerView
                $0.contentView = contentView
                $0.refreshControl = refreshControl
            }
        } else {
            nil
        }
    }()
    
    private lazy var refreshControl: UIRefreshControl? = {
        if configuration.isRefreshEnabled {
           UIRefreshControl()
        } else {
            nil
        }
    }()
    
    private lazy var configuration: NestedScrollingConfiguration = {
        let config = makeConfiguration()
        config.didAdd(to: self)
        
        return config
    }()
    
    private lazy var contentView = makeContentView()
    
    private var contentViewClosure: (() -> NestedScrollingContent)?
    private var configurationClosure: (() -> NestedScrollingConfiguration)?

    public convenience init(viewModel: ViewModel, contentView: @escaping @autoclosure () -> NestedScrollingContent, configuration: @escaping @autoclosure () -> NestedScrollingConfiguration) {
        self.init(viewModel: viewModel)
        
        self.contentViewClosure = contentView
        self.configurationClosure = configuration
    }
    
    open func makeContentView() -> NestedScrollingContent {
        if let contentViewClosure {
            return contentViewClosure()
        }
        
        fatalError("`makeContentView` must be implemented")
    }
    
    open func makeConfiguration() -> NestedScrollingConfiguration {
        if let configurationClosure {
            return configurationClosure()
        }
        
        fatalError("`makeConfiguration` must be implemented")
    }

    open override func setupUI() {
        if let nestedScrollingView {
            view.addSubview(nestedScrollingView)
            nestedScrollingView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.right.equalTo(view.safeAreaLayoutGuide)
            }
        } else {
            view.addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.right.equalTo(view.safeAreaLayoutGuide)
            }
        }
    }
    
    open override func performBinding() {
        super.performBinding()
            
        // Refresh data
        refreshControl?.isRefreshingPublisher
            .sink { [weak self] isRefreshing in
                guard let self, isRefreshing else { return }
                
                self.viewModel.loadData()
            }
            .store(in: &cancellables)
        
        // Parent content offset
        if let nestedScrollingView {
            nestedScrollingView.parentDidScrollPublisher
                .merge(with: nestedScrollingView.childDidScrollPublisher)
                .sink { [weak self] _ in
                    guard let self, let nestedScrollingView = self.nestedScrollingView else { return }
                    
                    self.configuration.parentContentOffsetDidChange(nestedScrollingView.parent.contentOffset.y)
                }
                .store(in: &cancellables)
        }
        
        // Loading status
        if let refreshControl {
            viewModel.$loadStatus.didChange
                .sink { [weak self] _ in
                    guard let self else { return }
                    
                    switch self.viewModel.loadStatus {
                    case .success, .failure:
                        refreshControl.endRefreshing()
                        
                    default:
                        break
                    }
                }
                .store(in: &cancellables)
        }
    }
}
