//
//  TabController.swift
//  llp_x_cloud_assemble_ios
//
//  Created by xueqooy on 2024/10/17.
//

import Combine
import SnapKit
import UIKit
import XKit

open class TabController: UIViewController {
    public enum TabBarState: Equatable {
        case normal
        case transparent
        case hidden(keepsSafeArea: Bool = false)

        var isHidden: Bool {
            switch self {
            case .hidden:
                return true
            default:
                return false
            }
        }

        var alpha: CGFloat {
            switch self {
            case .normal:
                1
            case .transparent:
                0.6
            case .hidden:
                0
            }
        }
    }

    public var tabs: [Tab] = [] {
        didSet {
            let identifiers = Set(tabs.map(\.identifier))
            Asserts.failure("Tab's identifier can't be duplicate", condition: identifiers.count == tabs.count)

            needReloadTabs = true
            reloadPagesIfNecessary()
        }
    }

    public var selectedIndex: Int {
        tabBar.selectedSegmentIndex
    }

    public var tabBarState: TabBarState = .normal {
        didSet {
            guard tabBarState != oldValue else {
                return
            }

            let currentAlpha = tabBar.alpha

            tabBar.alpha = tabBarState.alpha
            tabBar.layer.animateAlpha(from: currentAlpha, to: tabBarState.alpha, duration: 0.25)

            if tabBarState.isHidden || oldValue.isHidden {
                if tabBarState.isHidden {
                    tabBar.layer.transform = CATransform3DMakeTranslation(0, 30, 0)
                    tabBar.layer.animateTranslationY(from: 0, to: 30, duration: 0.25)
                } else {
                    tabBar.layer.transform = CATransform3DIdentity
                    tabBar.layer.animateTranslationY(from: 30, to: 0, duration: 0.25)
                }
            }

            updateAdditionalSafeAreaInsets()
        }
    }

    override open var shouldAutomaticallyForwardAppearanceMethods: Bool {
        false
    }

    private lazy var tabBar: SegmentControl = {
        let control = SegmentControl(style: .tab)
        control.selectionChanged = { [weak self] control in
            guard let self = self else {
                return
            }

            guard control.selectedSegmentIndex != self.tabPageView.selectedPageIndex else {
                return
            }

            tabPageView.selectPage(at: control.selectedSegmentIndex, animated: false)
        }

        return control
    }()

    private lazy var tabPageView: PageView = {
        let pageView = PageView()
        pageView.isScrollEnabled = false

        return pageView
    }()

    private var tabSubscriptions = Set<AnyCancellable>()

    private var needReloadTabs = false

    private let tabBarTopToSafeAreaBottomSpacing: CGFloat = .XUI.spacing4

    /// Used to set an additional bottom safe area to prevent views based on safe area layout from being covered by tabControl
    private var additionalSafeAreaInsetsForTabBar: UIEdgeInsets {
        let addition: CGFloat = if let originalSafeAreaInsets, originalSafeAreaInsets.bottom == 0 {
            // When the original bottom spacing of the safe area is 0, add additional spacing to prevent the tabBar from sticking to the bottom
            CGFloat.XUI.spacing4
        } else {
            0.0
        }

        return .init(top: 0, left: 0, bottom: tabBar.style.intrinsicHeight + tabBarTopToSafeAreaBottomSpacing + addition, right: 0)
    }

    private var originalSafeAreaInsets: UIEdgeInsets?

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.background1

        view.addSubview(tabPageView)
        tabPageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-40)

            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(tabBarTopToSafeAreaBottomSpacing)
        }

        tabPageView.dataSource = self
        tabPageView.viewController = self

        reloadPagesIfNecessary()
    }

    override open func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        updateAdditionalSafeAreaInsets()
    }

    override open func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        if originalSafeAreaInsets == nil {
            originalSafeAreaInsets = view.safeAreaInsets
        }
    }

    public func showTab(at index: Int, animated: Bool = true) {
        tabBar.setSelectedSegmentIndex(index, animated: animated)
    }

    private func reloadPagesIfNecessary() {
        guard needReloadTabs, isViewLoaded else {
            return
        }

        reloadPages()
        needReloadTabs = false
    }

    private func reloadPages() {
        tabPageView.reloadData()

        reloadTabItems()

        tabSubscriptions.removeAll()

        for tab in tabs {
            // Observe changes for Tab item
            tab.$tabItem
                .didChange
                .dropFirst()
                .sink { [weak self] _ in
                    guard let self else { return }

                    self.reloadTabItems()
                }
                .store(in: &tabSubscriptions)
        }
    }

    private func reloadTabItems() {
        tabBar.items = tabs.map(\.tabItem)
        tabBar.selectedSegmentIndex = 0
    }

    private func updateAdditionalSafeAreaInsets() {
        additionalSafeAreaInsets = switch tabBarState {
        case let .hidden(keepsSafeArea):
            if keepsSafeArea {
                additionalSafeAreaInsetsForTabBar
            } else {
                UIEdgeInsets.zero
            }

        default:
            additionalSafeAreaInsetsForTabBar
        }
    }
}

extension TabController: PageViewDataSource {
    public func numberOfPages(in _: PageView) -> Int {
        tabs.count
    }

    public func pageView(_: PageView, contentForPageAt index: Int) -> PageContent {
        tabs[index].navigationController
    }
}
