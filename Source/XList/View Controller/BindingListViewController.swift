//
//  BindingListViewController.swift
//  XUI
//
//  Created by xueqooy on 2024/10/19.
//

import Combine
import IGListDiffKit
import IGListKit
import UIKit
import XKit
import XUI

open class BindingListViewController<ViewModel: BindingListViewModel>: GenericBindingViewController<ViewModel> {
    public let listController = ListController().then {
        $0.canRefresh = true
    }

    public var canDisplayEmptyView: Bool = true {
        didSet {
            emptyView?.alpha = canDisplayEmptyView ? 1.0 : 0
        }
    }

    private var emptyView: EmptyView?

    override open func viewDidLoad() {
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

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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

        emptyView?.alpha = canDisplayEmptyView ? 1.0 : 0

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
            !listController.objects.isEmpty

        default:
            false
        }
    }

    // MARK: - Subclass Overrides

    open var shouldReloadEmptyViewWhenViewSizeChanged: Bool {
        true
    }

    /// Super required
    override open func setupUI() {
        view.addSubview(listController.listView)
        listController.listView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// Super required
    override open func performBinding() {
        super.performBinding()

        listController.refreshHandler = { [weak self] _ in
            guard let self = self else { return }

            self.viewModel.loadData()
        }

        listController.loadMoreHandler = { [weak self] _ in
            guard let self = self else { return }

            self.viewModel.loadMoreData()
        }

        viewModel.$objects.didChange
            .handleEvents(receiveOutput: { [weak self] objects in
                guard let self = self else {
                    return
                }

                // Ensure empty view is displaying when data is empty and not in loading
                if objects.isEmpty, !self.viewModel.loadStatus.isLoading {
                    self.emptyView?.configuration.isLoading = false
                }
            })
            .assign(to: \.objects, on: listController)
            .store(in: &cancellables)

        viewModel.$loadStatus.didChange
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

    open func sectionController(for _: ListDiffable) -> ListSectionController? {
        nil
    }

    open func makeEmptyConfiguration() -> EmptyConfiguration? {
        nil
    }
}
