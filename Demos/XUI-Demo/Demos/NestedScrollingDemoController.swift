//
//  NestedScrollingDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/7/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI
import XKit
import Combine

enum NestedContentType: String, CaseIterable {
    case nonScroll, scroll, pagedScroll
}

typealias NestedBounceTarget = NestedScrollingView.BounceTarget

extension NestedBounceTarget: @retroactive CaseIterable {
    public static var allCases: [NestedScrollingView.BounceTarget] = [.automatic, .parent, .child]
    
    var rawValue: String {
        switch self {
        case .parent:
            return "parent"
        case .child:
            return "child"
        case .automatic:
            return "automatic"
        @unknown default:
            fatalError()
        }
    }
}


class NestedScrollingDemoController: DemoController {
    private lazy var nestedScrollingView = NestedScrollingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        formView.itemSpacing = .XUI.spacing4
        
        let headerView = HeaderView()
        headerView.contentChanged = { [weak self] contentType in
            guard let self = self else {
                return
            }
            switch contentType {
            case .nonScroll:
                self.nestedScrollingView.showsScrollIndicator = true
                self.nestedScrollingView.contentView = ContentView()
            case .scroll:
                self.nestedScrollingView.showsScrollIndicator = false
                let scrollContentView = ScrollContentView()
                scrollContentView.childScrollView?.refreshControl = self.createRefreshControl()
                self.nestedScrollingView.contentView = scrollContentView
            case .pagedScroll:
                self.nestedScrollingView.showsScrollIndicator = false
                let pageContentView = PageContentView()
                pageContentView.refreshControlProvider = { [weak self] in
                    guard let self = self else {
                        return nil
                    }
                    return self.createRefreshControl()
                }
                self.nestedScrollingView.contentView = pageContentView

            }
        }
        headerView.bounceTargetChanged = { [weak self] bounceTarget in
            guard let self = self else {
                return
            }
            self.nestedScrollingView.bounceTarget = bounceTarget
        }
        
        headerView.automaticallyShowsHeaderChanged = { [weak self] automaticallyShowsHeader in
            guard let self = self else {
                return
            }
            
            self.nestedScrollingView.criticalValueForAutomaticHeaderDisplay = .fixed(50)
            self.nestedScrollingView.automaticallyShowsHeader = automaticallyShowsHeader
        }
        
//        nestedScrollingView.parent.contentInset = .init(top: 50, left: 0, bottom: 0, right: 0)
        nestedScrollingView.refreshControl = createRefreshControl()
        nestedScrollingView.headerView = headerView
        nestedScrollingView.contentView = ContentView()

        view.addSubview(nestedScrollingView)
        nestedScrollingView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        if sender.isRefreshing {
            Queue.main.execute(.delay(1.5)) {
                sender.endRefreshing()
            }
        }
    }
    
    private func createRefreshControl() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(Self.refresh(_:)), for: .valueChanged)
        return refreshControl
    }
}



private class HeaderView: UIView, NestedScrollingHeader {

    private let bounceTargetControl = SegmentControl(style: .toggle, items: NestedScrollingView.BounceTarget.allCases.map { .text($0.rawValue) })

    private let contentSegmentedControl = SegmentControl(style: .toggle, items: NestedContentType.allCases.map { .text($0.rawValue) })
        
    private let automaticallyShowsHeaderSwitch = OptionControl(style: .switch, titlePlacement: .leading, title: "automatically Shows Header")
    
    var contentChanged: ((NestedContentType) -> Void)?
    var bounceTargetChanged: ((NestedBounceTarget) -> Void)?
    var automaticallyShowsHeaderChanged: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Colors.background1
        
        let formView = FormView(contentScrollingBehavior: .disabled)
        addSubview(formView)
        formView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        formView.populate {
            FormRow(contentSegmentedControl, alignment: .center)
            FormRow(bounceTargetControl, alignment: .center)
            FormRow(automaticallyShowsHeaderSwitch, alignment: .center)
        }
       
        
        contentSegmentedControl.selectedSegmentIndex = 0
        contentSegmentedControl.selectionChanged = { [weak self] control in
            guard let self = self else {
                return
            }
            var contentType: NestedContentType
            switch control.selectedSegmentIndex {
            case 0:
                contentType = .nonScroll
            case 1:
                contentType = .scroll
            default:
                contentType = .pagedScroll
            }
            self.contentChanged?(contentType)
        }
        
        bounceTargetControl.selectedSegmentIndex = 0
        bounceTargetControl.selectionChanged = { [weak self] control in
            guard let self = self else {
                return
            }
            var bounceTarget: NestedBounceTarget = NestedBounceTarget.allCases[control.selectedSegmentIndex]
            self.bounceTargetChanged?(bounceTarget)
        }
        
        automaticallyShowsHeaderSwitch.seletionStateChangedAction = { [weak self] in
            guard let self else { return }
            
            self.automaticallyShowsHeaderChanged?($0.isSelected)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class ContentView: RandomGradientView, NestedScrollingContent {
}

private class ScrollContentView: UIView, NestedScrollingContent {
    let childScrollView: UIScrollView? = RandomGradientScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let childScrollView = childScrollView {
            
            addSubview(childScrollView)
            childScrollView.snp.makeConstraints({ make in
                make.size.equalToSuperview()
                make.top.leading.equalToSuperview()
            })
            childScrollView.contentSize = CGSize(width: 0, height: 2000)            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class PageContentView: SegmentedPageView, SegmentedPageViewDataSource {
    class PageView: RandomGradientView {}
    
    var refreshControlProvider: (() -> UIRefreshControl?)?
    
    class PageScrollView: RandomGradientScrollView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            
//            contentInset = .init(top: 50, left: 0, bottom: 0, right: 0)
            
            contentSize = CGSize(width: 0, height: 2000)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    init() {
        super.init()
        
        self.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfPages(in pageView: XUI.PageView) -> Int {
        10
    }
    
    func pageView(_ pageView: XUI.PageView, contentForPageAt index: Int) -> XUI.PageContent {
        let scrollView = PageScrollView()
        scrollView.refreshControl = refreshControlProvider?()
        return scrollView
    }
    
    func pageView(_ segmentedPageView: XUI.SegmentedPageView, segmentItemForPageAt index: Int) -> XUI.SegmentedPageView.SegmentItem {
        .text("Page \(index)")
    }
}
