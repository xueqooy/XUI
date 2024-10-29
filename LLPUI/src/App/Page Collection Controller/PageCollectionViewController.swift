//
//  PageCollectionViewController.swift
//  LLPUI
//
//  Created by xueqooy on 2024/10/19.
//

import UIKit
import LLPUtils
import Combine

/// Page collection with title
open class PageCollectionViewController<ViewModel: PageCollectionViewModel>: BindingViewController<ViewModel> {
        
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        false
    }

    private lazy var nestedScrollingView: NestedScrollingView? = {
        if let navigationTitleView {
            NestedScrollingView(stickyHeader: Device.current.isPad).then {
                $0.automaticallyShowsHeader = true
                // Set it to never here, and the external safe area can be passed to the child interface (the parent scroll view may be set to automatic, which will cause the automatic behavior of the child scroll view to fail)
                $0.parent.contentInsetAdjustmentBehavior = .never
                $0.headerView = titleView
                $0.contentView = segmentedPageView
                $0.refreshControl = refreshControl
            }
        } else {
            nil
        }
    }()
    
    private lazy var refreshControl = UIRefreshControl()

    private lazy var navigationTitleView: PageCollectionTitleView? = {
        if Device.current.isPhone, !(viewModel.title ?? "").isEmpty {
            PageCollectionTitleView(style: .navigation, title: viewModel.title)
        } else {
            nil
        }
    }()
    
    private lazy var titleView: PageCollectionTitleView? = {
        if  !(viewModel.title ?? "").isEmpty {
            PageCollectionTitleView(title: viewModel.title)
        } else {
            nil
        }
    }()
        
    private lazy var segmentedPageView: SegmentedPageView = {
        let view = SegmentedPageView()
        view.viewController = self
        view.dataSource = self
        
        return view
    }()
    
    open override func setupUI() {
        if let navigationTitleView {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navigationTitleView)
        }
        
        if let titleView {
            if let nestedScrollingView {
                // Title view's position is animated
                
                view.addSubview(nestedScrollingView)
                nestedScrollingView.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.left.right.equalTo(view.safeAreaLayoutGuide)
                }
            } else {
                // Title view's position  is fixed
                view.addSubview(titleView)
                titleView.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.left.right.equalTo(view.safeAreaLayoutGuide)
                }
                
                view.addSubview(segmentedPageView)
                segmentedPageView.snp.makeConstraints { make in
                    make.top.equalTo(titleView.snp.bottom)
                    make.bottom.equalToSuperview()
                    make.left.right.equalTo(view.safeAreaLayoutGuide)
                }
            }
        } else {
            // Title view is hidden
            view.addSubview(segmentedPageView)
            segmentedPageView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.right.equalTo(view.safeAreaLayoutGuide)
            }
        }
    }
   
    open override func performBinding() {
        // Initial load
        viewStatePublisher
            .filter { $0 == .isAppearing }
            .first()
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.viewModel.loadData()
            }
            .store(in: &cancellables)
    
        // Update the offset of titleView according to the scroll offset to achieve the displacement transition effect of the title
        if let navigationTitleView, let nestedScrollingView {
            nestedScrollingView.parentDidScrollPublisher
                .merge(with: nestedScrollingView.childDidScrollPublisher)
                .sink { [weak self] _ in
                    guard let nestedScrollingView = self?.nestedScrollingView else { return }
                    
                    navigationTitleView.offset = -nestedScrollingView.parent.contentOffset.y
                }
                .store(in: &cancellables)
        }
        

        // Input
        
        // Refresh data
        refreshControl.isRefreshingPublisher
            .sink { [weak self] isRefreshing in
                guard let self, isRefreshing else { return }
                
                self.viewModel.loadData()
            }
            .store(in: &cancellables)
        
        
        // Output
        
        // Reload Pages
        viewModel.$pages.didChange
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.segmentedPageView.reloadData()
            }
            .store(in: &cancellables)
        
        // Loading status
        viewModel.$status.didChange
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.handleStatusChanged()
            }
            .store(in: &cancellables)
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Update the state when the view size changes (the empty view may be displayed differently in landscape and portrait modes)）
        self.handleStatusChanged()
    }
    
    private func handleStatusChanged() {
        switch viewModel.status {
        case .idle, .loading:
            segmentedPageView.emptyConfiguraiton.isLoading = true
     
        case .loaded:
            if viewModel.pages.isEmpty {
                segmentedPageView.emptyConfiguraiton = .noRelevantContentFound()
            }
            
            segmentedPageView.emptyConfiguraiton.isLoading = false
            refreshControl.endRefreshing()
            
        case .failed(let error):
            segmentedPageView.emptyConfiguraiton = .somethingWentWrong { [weak self] in
                guard let self else { return }
                
                self.viewModel.loadData()
            }
            refreshControl.endRefreshing()
        }
    }
}

extension PageCollectionViewController: SegmentedPageViewDataSource {
    public func pageView(_ segmentedPageView: LLPUI.SegmentedPageView, segmentItemForPageAt index: Int) -> LLPUI.SegmentedPageView.SegmentItem {
        viewModel.pages[index].segmentItem
    }
    
    public func numberOfPages(in pageView: LLPUI.PageView) -> Int {
        viewModel.pages.count
    }
    
    public func pageView(_ pageView: LLPUI.PageView, contentForPageAt index: Int) -> LLPUI.PageContent {
        viewModel.pages[index].viewController
    }
}
