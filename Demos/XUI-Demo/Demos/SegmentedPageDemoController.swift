//
//  SegmentedPageDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/7/18.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI
import XKit
import Combine

class SegmentedPageDemoController: DemoController {
    
    private lazy var pageView = SegmentedPageView()

    private let pagesSubject = CurrentValueSubject<[String], Never>([])
    
    private var pages: [String] {
        pagesSubject.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(Self.reload))
        navigationItem.rightBarButtonItem = buttonItem
        
        pageView.viewController = self
        pageView.dataSource = self
        pageView.delegate = self
        pageView.selectPage(at: 2, animated: false)
        
        view.addSubview(pageView)
        pageView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        pagesSubject.sink { [weak self] _ in
            self?.pageView.reloadData()
        }.store(in: &cancellables)
        
        Queue.main.execute(.delay(0.1)) {
            self.pagesSubject.send(["Posts", "Folders", "Members", "Upcoming", "Small Group"])
        }
    }
    
    @objc private func reload() {
        pageView.reloadData()
    }
}

extension SegmentedPageDemoController: SegmentedPageViewDataSource {
//    func numberOfPages(in pageView: SegmentedPageView) -> Int {
//        (0...7).randomElement() ?? 1
//    }
//    
//    func segmentedPageView(_ segmentedPageView: SegmentedPageView, contentForPageAt index: Int) -> SegmentedPageContent {
//        if index == 3 || index == 5 || index == 6 {
//            let view = PageContentView()
//            view.startLoadingAutomatically = true
//            view.name = "Page \(index)"
//            return view
//        } else {
//            let viewController = PageContentViewController()
//            viewController.name = "Page \(index)"
//            return viewController
//        }
//    }
//    
//    func segmentedPageView(_ segmentedPageView: SegmentedPageView, segmentItemForPageAt index: Int) -> SegmentedPageView.SegmentItem {
//        if index == 3 || index == 5 || index == 6 {
//            return .badgedText("Page \(index)")
//        } else {
//            return .text("Page \(index)")
//        }
//    }
    
    func numberOfPages(in pageView: PageView) -> Int {
        pages.count
    }
    
    
    func pageView(_ segmentedPageView: PageView, contentForPageAt index: Int) -> PageContent {
        let viewController = PageContentViewController()
        viewController.name = pages[index]
        return viewController
    }
    
    func pageView(_ segmentedPageView: SegmentedPageView, segmentItemForPageAt index: Int) -> SegmentedPageView.SegmentItem {
        .text(pages[index])
    }
    
}

extension SegmentedPageDemoController: PageViewDelegate {
    
    func pageView(_ pageView: PageView, didSelectPageAt index: Int) {
        print("select \(index) \(String(describing: pageView.contentForPage(at: index)))")
    }
}


private class PageContentView: RandomGradientView {
    
    private let activityIndicator = ActivityIndicatorView()
    
    var name: String = ""

    var startLoadingAutomatically: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if startLoadingAutomatically {
            print("\(name) loading")
            
            startLoading()
            Queue.main.execute(.delay(1.5)) { [weak self] in
                guard let self = self else {
                    return
                }
                self.stopLoading()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
        self.gradientLayer.isHidden = true
    }
    
    func stopLoading() {
        self.gradientLayer.isHidden = false
        self.activityIndicator.stopAnimating()
    }
}

private class PageContentViewController: UIViewController {
    
    private var cancellable: AnyCancellable?
    
    var name: String = ""
    
    override func loadView() {
        self.view = PageContentView()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        cancellable = viewStatePublisher.sink { [weak self] viewState in
            guard let self = self else {
                return
            }
            print("\(self.name) \(viewState)")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (view as! PageContentView).startLoading()
        Queue.main.execute(.delay(1.5)) { [weak self] in
            guard let self = self else {
                return
            }
            (self.view as! PageContentView).stopLoading()
        }
    }
    
//    override func willMove(toParent parent: UIViewController?) {
//        super.willMove(toParent: parent)
//        
//        print("\(self.name) willMoveTo \(String(describing: parent))")
//    }
//    
//    override func didMove(toParent parent: UIViewController?) {
//        super.didMove(toParent: parent)
//        
//        print("\(self.name) didMoveTo \(String(describing: parent))")
//    }
}
