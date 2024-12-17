//
//  PageView.swift
//  XUI
//
//  Created by xueqooy on 2023/7/18.
//

import UIKit
import Combine
import XKit

public protocol PageContent {
    var pageContentView: UIView { get }
}

extension UIView: PageContent {
    public var pageContentView: UIView {
        self
    }
}

extension UIViewController: PageContent {
    public var pageContentView: UIView {
        view
    }
}


public protocol PageViewDelegate: AnyObject {
    func pageView(_ pageView: PageView, didSelectPageAt index: Int)
}

public protocol PageViewDataSource: AnyObject {
    func numberOfPages(in pageView: PageView) -> Int
    
    func pageView(_ pageView: PageView, contentForPageAt index: Int) -> PageContent
}


/// A page view with segmented control, the displayed content is loaded lazily.
/// The pageContent can be either `UIView` or `UIViewController`
/// `UIViewController` Appearance transition will be automatically managed
open class PageView: UIView {
    
    public var selectedPageIndex: Int {
        set {
            guard newValue != innerSelectedPageIndex else {
                return
            }
            
            selectPage(at: newValue, animated: false)
        }
        get {
            innerSelectedPageIndex
        }
    }
    
    public weak var dataSource: PageViewDataSource? {
        didSet {
            guard oldValue !== dataSource else {
                return
            }
            
            didLoadData = false
            innerSelectedPageIndex = 0
            numberOfPages = dataSource?.numberOfPages(in: self) ?? 0
            
            loadDataIfNeeded()
        }
    }
    
    public weak var delegate: PageViewDelegate?
    
    @EquatableState
    public private(set) var numberOfPages: Int = 0
    
    public var didSelectPagePublisher: AnyPublisher<Int, Never> {
        didSelectPageSubject.eraseToAnyPublisher()
    }
    private let didSelectPageSubject = PassthroughSubject<Int, Never>()
    
    /// The view controller that houses the view.
    /// - note: view controller's shouldAutomaticallyForwardAppearanceMethods should be false.
    public weak var viewController: UIViewController? {
        didSet {
            guard oldValue !== viewController else {
                return
            }
            
            if dataSource != nil, didLoadData {
                reloadData()
            }
            
            lifecycleSubscription = nil
    
            if let viewController {
                if !viewController.shouldAutomaticallyForwardAppearanceMethods {
                    // Manually forward appearance methods for current content
                    lifecycleSubscription = viewController.viewStatePublisher
                        .sink { [weak self] viewState in
                            guard let self, let currentContent = self.loadedContents[self.innerSelectedPageIndex] as? UIViewController else { return }
                            
                            switch viewState {
                            case .willAppear:
                                currentContent.beginAppearanceTransition(true, animated: true)
                    
                            case .willDisappear:
                                currentContent.beginAppearanceTransition(false, animated: true)
                                
                            case .didDisappear, .didAppear:
                                currentContent.endAppearanceTransition()
                            default:
                                break
                            }
                        }
                    
                } else {
                    Logs.warn("""
                        The parent view controller should not automatically forward appearance methods, it may cause incorrect appearance transition for child view controllers.
                        
                        The appearance methods of parent view controller will be forwarded to all children simultaneously, which is not what we want. It should be forwarded to the selected child view controller.
                        """)
                }
            }
        }
    }
    
    /// The display of EmptyView is automatic. When PageView has no pages to display, EmptyView will be displayed
    public var emptyConfiguraiton: EmptyConfiguration {
        set {
            emptyView.configuration = newValue
            
            setupEmptyView()
        }
        get {
            emptyView.configuration
        }
    }
    
    public var isScrollEnabled: Bool {
        get {
            scrollView.isScrollEnabled
        }
        set {
            scrollView.isScrollEnabled = newValue
        }
    }
    
    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    
    private lazy var emptyView = EmptyView().settingHidden(true)
    
    private var didAddEmptyView = false
    
    private var emptyViewVisibilitySubscription: AnyCancellable?
    
        
    private var loadedContents = [Int : PageContent]()
    
    /// Has  `reloadData` been called after setting the dataSource.
    private var didLoadData: Bool = false
    
    private var innerSelectedPageIndex: Int = 0 {
        didSet {
            guard oldValue != innerSelectedPageIndex else {
                return
            }
            
            delegate?.pageView(self, didSelectPageAt: innerSelectedPageIndex)
            didSelectPageSubject.send(innerSelectedPageIndex)
        }
    }
    
    private var lifecycleSubscription: AnyCancellable?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        
        loadDataIfNeeded()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        updateScrollContentSize()
        updateScrollContentOffset(animated: false)
        
        layoutContents()
    }
    
    public func reloadData() {
        didLoadData = false
        defer {
            didLoadData = true
        }
        
        numberOfPages = dataSource?.numberOfPages(in: self) ?? 0
        
        removeContents()
        updateScrollContentSize()

        guard numberOfPages > 0 else {
            return
        }
        
        //  Keep previous selected page index as possible
        let selectedPageIndex = max(0, min(innerSelectedPageIndex, numberOfPages - 1))
        updateSelectedPageIndex(selectedPageIndex, animated: false)
        
        delegate?.pageView(self, didSelectPageAt: innerSelectedPageIndex)
        didSelectPageSubject.send(innerSelectedPageIndex)
    }
    
    public func selectPage(at index: Int, animated: Bool) {
        if !didLoadData {
            innerSelectedPageIndex = index
            return
        }
        
        let originalIndex = index
        let index = max(0, min(index, numberOfPages - 1))
        
        Logs.error("Invalid page index: \(originalIndex)", condition: originalIndex != index)
        
        let fromIndex = self.innerSelectedPageIndex
        
        guard fromIndex != index else {
            return
        }
        
        let didLoadTargetContentBefore = self.loadedContents[index] != nil
        
        self.updateSelectedPageIndex(index, animated: animated)
    
        // beginAppearanceTransition(true) has been called for newly-created content
        self.beginAppearanceTransition(from: fromIndex, to: didLoadTargetContentBefore ? index : nil)
        self.endApperanceTransition(from: fromIndex, to: index)
    }
 
    /// Returns any loaded content for the page. Returns nil when no content loads.
    public func contentForPage(at index: Int) -> PageContent? {
        loadedContents[index]
    }
    
    public func updateEmptyConfiguration(_ modifier: (inout EmptyConfiguration) -> Void) {
        modifier(&emptyConfiguraiton)
    }
    
    // MARK: - Private

    private func loadDataIfNeeded() {
        if window != nil && !didLoadData {
            reloadData()
        }
    }
    
    private func updateSelectedPageIndex(_ index: Int, animated: Bool) {
        maybeLoadContent(at: index)
        innerSelectedPageIndex = index
        updateScrollContentOffset(animated: animated)
    }

    /// Return `true` if content is  newly created.
    @discardableResult private func maybeLoadContent(at index: Int) -> Bool {
        guard loadedContents[index] == nil, let dataSource = dataSource else {
            return false
        }
        
        let content = dataSource.pageView(self, contentForPageAt: index)
        let pageContentView = content.pageContentView
        
        if let child = content as? UIViewController {
            
            if let parent = self.viewController {
                parent.addChild(child)
                child.didMove(toParent: parent)
                
                if didLoadData {
                    // This prevents the system from firing viewDidAppear, but keep viewWillAppear.
                    // We need to manually end the appearance transition after the content is selected
                    child.beginAppearanceTransition(true, animated: true)
                    
                } else if !parent.shouldAutomaticallyForwardAppearanceMethods {
                    // System will not fire viewWillAppear and viewDidAppear
                    // We need to manually begin and end the appearance transition
                    child.beginAppearanceTransition(true, animated: true)
                    child.endAppearanceTransition()
                } /* else {
                   // Will automatically fire viewWillAppear and viewDidAppear.
                }*/
            } else {
                Logs.error("Missing parent view controller, will cause that child view controller being detached, and may result in incorrect safe area insets and a corrupt root presentation")
            }
        }
                
        scrollView.addSubview(pageContentView)
        
        loadedContents[index] = content
        layoutContent(at: index)
        
        return true
    }
    
    private func layoutContents() {
        loadedContents.keys.forEach { layoutContent(at: $0) }
    }
    
    private func layoutContent(at index: Int) {
        guard let pageContentView = loadedContents[index]?.pageContentView else {
            return
        }
        
        let pageSize = scrollView.bounds.size
        let originX = CGFloat(index) * pageSize.width
        
        pageContentView.snp.remakeConstraints { make in
            make.size.equalTo(pageSize).priority(.required)
            make.top.equalToSuperview().priority(.required)
            make.left.equalToSuperview().offset(originX).priority(.required)
        }
    }
    
    private func removeContents() {
        for (_, content) in loadedContents {
            content.pageContentView.removeFromSuperview()
            
            if let viewController = content as? UIViewController {
                viewController.willMove(toParent: nil)
                viewController.removeFromParent()
            }
        }
        loadedContents.removeAll()
    }

    private func updateScrollContentSize() {
        guard numberOfPages > 0 else {
            scrollView.contentSize = .zero
            return
        }
        
        let contentSize = CGSize(width: CGFloat(numberOfPages) * scrollView.bounds.width, height: scrollView.bounds.height)
        if scrollView.contentSize != contentSize {
            scrollView.contentSize = contentSize
        }
    }
    
    private func updateScrollContentOffset(animated: Bool) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(innerSelectedPageIndex) * scrollView.bounds.width, y: 0), animated: animated)
    }
    
    private func updatePageBasedOnScrollingOffset() {
        var page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        page = max(0, min(numberOfPages, page))
        selectPage(at: page, animated: false)
    }
    
    private func setupEmptyView() {
        guard emptyView.superview != self else { return }
        
        addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        didAddEmptyView = true
        
        // Tracking pages changes to update empty view visibility
        emptyViewVisibilitySubscription = $numberOfPages.didChange
            .sink { [weak self] numberOfPages in
                self?.emptyView.isHidden = numberOfPages > 0
            }
    }
    
    
    // MARK: - Appearance Transition
    
    private func beginAppearanceTransition(from fromIndex: Int?, to toIndex: Int?) {
        guard fromIndex != toIndex else {
            return
        }
        
        let fromViewController = fromIndex != nil ? loadedContents[fromIndex!] as? UIViewController : nil
        let toViewController = toIndex != nil ? loadedContents[toIndex!] as? UIViewController : nil
        
        fromViewController?.beginAppearanceTransition(false, animated: true)
        toViewController?.beginAppearanceTransition(true, animated: true)
    }
    
    private func endApperanceTransition(from fromIndex: Int?, to toIndex: Int?) {
        guard fromIndex != toIndex else {
            return
        }
        
        let fromViewController = fromIndex != nil ? loadedContents[fromIndex!] as? UIViewController : nil
        let toViewController = toIndex != nil ? loadedContents[toIndex!] as? UIViewController : nil
        
        fromViewController?.endAppearanceTransition()
        toViewController?.endAppearanceTransition()
    }
    
    
    // MARK: - Dragging
    
    private var draggingProbablePageIndex: Int?
    
    private func handleDragging() {
        let scrollOffset = scrollView.contentOffset.x
        let pageWidth = scrollView.bounds.width
        let leftPageIndex = Int(max(0.0, floor(scrollOffset / pageWidth)))
        let rightPageIndex = Int(min(CGFloat(numberOfPages) - 1.0,  ceil(scrollOffset / pageWidth)))
        
        guard leftPageIndex != rightPageIndex else {
            return
        }
        
        let ProbablePageIndex = leftPageIndex == innerSelectedPageIndex ? rightPageIndex : leftPageIndex
        guard ProbablePageIndex != draggingProbablePageIndex else {
            return
        }
        if let previousDraggingProbablePageIndex = draggingProbablePageIndex {
            // e.g. Dragging from page2 to page1 and then to page3, We need to fire viewWillDisappear and viewDidDisappear for page1
            beginAppearanceTransition(from: previousDraggingProbablePageIndex, to: nil)
            endApperanceTransition(from: previousDraggingProbablePageIndex, to: nil)
        }
        
        draggingProbablePageIndex = ProbablePageIndex
        
        if maybeLoadContent(at: ProbablePageIndex) {
            // beginAppearanceTransition(true) has been called for newly-created content
            beginAppearanceTransition(from: innerSelectedPageIndex, to: nil)
        } else {
            beginAppearanceTransition(from: innerSelectedPageIndex, to: ProbablePageIndex)
        }
    }
    
    private func handleAfterDraggingAndScrollingStop() {
        let previousPageIndex = innerSelectedPageIndex
        
        updatePageBasedOnScrollingOffset()
        
        if previousPageIndex == innerSelectedPageIndex {
            // Not dragged to probable page
            beginAppearanceTransition(from: draggingProbablePageIndex, to: previousPageIndex)
            endApperanceTransition(from: draggingProbablePageIndex, to: previousPageIndex)
        } else {
            // Did drag to probable page
            endApperanceTransition(from: previousPageIndex, to: draggingProbablePageIndex)
        }
                
        draggingProbablePageIndex = nil
    }
}

extension PageView: UIScrollViewDelegate {
        
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else {
            return
        }
        
        handleDragging()
    }
    
    // Call after dragging
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        
        handleAfterDraggingAndScrollingStop()
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleAfterDraggingAndScrollingStop()
    }
    
}
