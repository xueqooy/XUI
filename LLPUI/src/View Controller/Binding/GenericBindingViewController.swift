//
//  GenericBindingViewController.swift
//  Pods
//
//  Created by xueqooy on 2024/11/20.
//

open class GenericBindingViewController<ViewModel: GenericBindingViewModel>: BindingViewController<ViewModel> {
    
    /// Reload data when view is appearing
    public var alwaysReloadDataWhenAppearing: Bool = false
    
    public private(set) var hasRequestedData = false
    
    // Super required
    open override func performBinding() {
        viewStatePublisher
            .filter { $0 == .isAppearing }
            .sink { [weak self] _ in
                guard let self, !self.viewModel.loadStatus.isLoading else { return }
                
                if !self.hasRequestedData || self.alwaysReloadDataWhenAppearing {
                    self.viewModel.loadData()
                }
                
                self.hasRequestedData = true
            }
            .store(in: &cancellables)
    }
}
