//
//  SegmentedPageViewController..swift
//  Pods
//
//  Created by xueqooy on 2024/11/20.
//

import UIKit
import XKit
import Combine

/// Page collection with title
open class SegmentedPageViewController<ViewModel: SegmentedPageViewModel>: NestedScrollingViewController<ViewModel> {
        
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        false
    }

    private lazy var segmentedPageView: SegmentedPageView = {
        let view = SegmentedPageView()
        view.viewController = self
        view.dataSource = self
        
        return view
    }()
   
    private var configurationClosure: (() -> NestedScrollingConfiguration)?
    
    public convenience init(viewModel: ViewModel, configuraiton: @escaping @autoclosure () -> NestedScrollingConfiguration) {
        self.init(viewModel: viewModel)
        
        self.configurationClosure = configuraiton
        self.configurationClosure = configuraiton
    }
    
    @available(*, unavailable, message: "Please use init(viewModel:configuraiton:) instead")
    public convenience init(viewModel: ViewModel, contentView: @escaping @autoclosure () -> NestedScrollingContent, configuraiton: @escaping @autoclosure () -> NestedScrollingConfiguration) {
        fatalError("Please use init(viewModel:configuraiton:) instead")
    }
    
    open override func makeConfiguration() -> NestedScrollingConfiguration {
        configurationClosure?() ?? .init()
    }
    
    public override func makeContentView() -> any NestedScrollingContent {
        segmentedPageView
    }
   
    open override func performBinding() {
        super.performBinding()
            
        // Reload Pages
        viewModel.$pages.didChange
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.segmentedPageView.reloadData()
            }
            .store(in: &cancellables)
        
        // Loading status
        viewModel.$loadStatus.didChange
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
        switch viewModel.loadStatus {
        case .idle, .loading:
            segmentedPageView.emptyConfiguraiton.isLoading = true
     
        case .success:
            if viewModel.pages.isEmpty {
                segmentedPageView.emptyConfiguraiton = .noRelevantContentFound()
            }
            
            segmentedPageView.emptyConfiguraiton.isLoading = false
            
        case .failure(let error):
            segmentedPageView.emptyConfiguraiton = .somethingWentWrong { [weak self] in
                guard let self else { return }
                
                self.viewModel.loadData()
            }
        }
    }
}

extension SegmentedPageViewController: SegmentedPageViewDataSource {
    public func pageView(_ segmentedPageView: XUI.SegmentedPageView, segmentItemForPageAt index: Int) -> XUI.SegmentedPageView.SegmentItem {
        viewModel.pages[index].segmentItem
    }
    
    public func numberOfPages(in pageView: XUI.PageView) -> Int {
        viewModel.pages.count
    }
    
    public func pageView(_ pageView: XUI.PageView, contentForPageAt index: Int) -> XUI.PageContent {
        viewModel.pages[index].viewController
    }
}
