//
//  NestedScrollingView.swift
//  CombineCocoa
//
//  Created by xueqooy on 2023/7/18.
//

import UIKit
import LLPUtils
import Combine

public protocol NestedScrollingHeader: UIView {
    var headerHeight: CGFloat { get }
}

public extension NestedScrollingHeader {
    var headerHeight: CGFloat {
        .LLPUI.automaticDimension
    }
}


public protocol NestedScrollingContent: UIView {
    var childScrollView: UIScrollView? { get }
    var childScrollViewDidChangePublisher: AnyPublisher<UIScrollView?, Never>? { get }
    var nonSimultaneousGestureRecognizers: [UIGestureRecognizer]? { get }
}

public extension NestedScrollingContent {
    var childScrollView: UIScrollView? { nil }
    var childScrollViewDidChangePublisher: AnyPublisher<UIScrollView?, Never>? { nil }
    var nonSimultaneousGestureRecognizers: [UIGestureRecognizer]? { nil }
}

open class NestedScrollingView: UIView {
        
    public enum BounceTarget {
        case automatic // parent or child, depending on whether the parent or child scroll view is being touched
        case parent
        case child
    }
        
    public var bounceTarget: BounceTarget = .automatic
    
    public var headerView: NestedScrollingHeader? {
        didSet {
            headerContainerView.headerView = headerView
        }
    }
    
    public var contentView: NestedScrollingContent? {
        didSet {
            observeChildScrolling(for: contentView?.childScrollView)
            
            childScrollViewDidChangeCancellable = contentView?.childScrollViewDidChangePublisher?
                .sink(receiveValue: { [weak self] scrollView in
                    guard let self = self else {
                        return
                    }
                    
                    self.observeChildScrolling(for: scrollView)
                })
            
            contentContainerView.contentView = contentView
            
            parentScrollView.nonSimultaneousGestureRecognizers = contentView?.nonSimultaneousGestureRecognizers ?? []
        }
    }
    
    public var refreshControl: UIRefreshControl? {
        get {
            parentScrollView.refreshControl
        }
        set {
            parentScrollView.refreshControl = newValue
        }
    }
    
    public var showsScrollIndicator: Bool {
        get {
            parentScrollView.showsVerticalScrollIndicator
        }
        set {
            parentScrollView.showsVerticalScrollIndicator = newValue
        }
    }
    
    /// If setting to  true,  NestedScrollingView will show the header when scrolling less than critical point  and hide it when scrolling greater than critical point
    public var automaticallyShowsHeader: Bool = false
    
    public enum CriticalValue {
        case fixed(CGFloat)
        case fraction(CGFloat)
    }
    
    /// The critical offset value for
    public var criticalValueForAutomaticHeaderDisplay: CriticalValue = .fraction(0.5)
    
    public var parent: UIScrollView {
        parentScrollView
    }
    
    public var currentChild: UIScrollView? {
        childScrollView
    }
    
    @EquatableState
    public private(set) var isDragging: Bool = false
    
    public var parentDidScrollPublisher: AnyPublisher<UIScrollView, Never> {
        parentDidScrollSubject.eraseToAnyPublisher()
    }
    
    public var childDidScrollPublisher: AnyPublisher<UIScrollView, Never> {
        childDidScrollSubject.eraseToAnyPublisher()
    }
    
    public var willBeginDraggingPublisher: AnyPublisher<Void, Never> {
        willBeginDraggingSubject.eraseToAnyPublisher()
    }
    
    public var didEndDraggingPublisher: AnyPublisher<Void, Never> {
        didEndDraggingSubject.eraseToAnyPublisher()
    }
    
    private let parentScrollView = NestedParentScrollView()
    private weak var childScrollView: UIScrollView?
    private let headerContainerView = NestedHeaderContainerView()
    private let contentContainerView = NestedContentContainerView()
            
    private var parentScrollOffsetObservation: NSKeyValueObservation?
    private var childScrollOffsetObservation: NSKeyValueObservation?
    private var childScrollViewDidChangeCancellable: AnyCancellable?
    
    private var canScrollParent: Bool = true
    private var canScrollChild: Bool = false
    private var lastChildBounceTranslation: CGFloat = 0
    
    private let parentDidScrollSubject = PassthroughSubject<UIScrollView, Never>()
    private let childDidScrollSubject = PassthroughSubject<UIScrollView, Never>()
    private let willBeginDraggingSubject = PassthroughSubject<Void, Never>()
    private let didEndDraggingSubject = PassthroughSubject<Void, Never>()

    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        parentScrollView.delegate = self
        
        setupViews()
        observeParentScrollling()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        headerContainerView.contentContainerView = contentContainerView
        
        addSubview(parentScrollView)
        parentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        parentScrollView.addSubview(headerContainerView)
        headerContainerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
        
        parentScrollView.addSubview(contentContainerView)
        contentContainerView.snp.remakeConstraints { make in
            make.top.equalTo(headerContainerView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
            make.size.equalTo(self)
        }
    }
        
    private func observeParentScrollling() {
        parentScrollOffsetObservation = parentScrollView.observe(\.contentOffset, options: [.new, .old]) { [weak self] scrollView, change in
            guard let self = self, change.newValue != change.oldValue else {
                return
            }
            self.parentScrollViewDidScroll(scrollView)
        }
    }
    
    private func observeChildScrolling(for childScrollView: UIScrollView?) {
        self.childScrollView = childScrollView

        if let childScrollView = childScrollView {
            // Reset content offset when parent can scroll
            if canScrollParent {
                childScrollView.scrollToTop(forced: true, animated: false)
            }
            childScrollOffsetObservation = childScrollView.observe(\.contentOffset, options: [.new, .old]) { [weak self] scrollView, change in
                guard let self = self, change.newValue != change.oldValue else {
                    return
                }
                self.childScrollViewDidScroll(scrollView)
            }
        } else {
            canScrollParent = true
            canScrollChild = false
             
            childScrollOffsetObservation = nil
        }
    }
    
    // MARK: - Bounce
    
    private var touchedChildScrollViewRecently: Bool = false
    
    private var shouldBounceParent: Bool {
        guard let currentChild else {
            return true
        }
        
        switch bounceTarget {
        case .parent:
            return true
        case .child:
            return false
        case .automatic:
            return !touchedChildScrollViewRecently
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        touchedChildScrollViewRecently = false
        if let currentChild {
            let childScrollRect = currentChild.convert(currentChild.bounds, to: self)
            if childScrollRect.contains(point) {
                touchedChildScrollViewRecently = true
            }
        }
        
        return super.point(inside: point, with: event)
    }
    
    // MARK: - Handle Scrolling
    
    private func parentScrollViewDidScroll(_ parentScrollView: UIScrollView) {
        let parentOffset = parentScrollView.contentOffset.y
        let headerHeight = headerView?.bounds.height ?? 0
        
        if shouldBounceParent {
            if !canScrollParent {
                parentScrollView.contentOffset.y = headerHeight
                canScrollChild  = true
            } else if parentOffset >= headerHeight {
                if childScrollView != nil {
                    parentScrollView.contentOffset.y = headerHeight
                    canScrollParent = false
                    canScrollChild = true
                }
            }
        } else {
            let childBounceTranslation = -parentScrollView.panGestureRecognizer.translation(in: parentScrollView).y.rounded(.up)
            defer {
                lastChildBounceTranslation = childBounceTranslation
            }
            
            if !canScrollParent {
                parentScrollView.contentOffset.y = headerHeight
                canScrollChild = true
            } else if parentOffset >= headerHeight {
                if childScrollView != nil {
                    parentScrollView.contentOffset.y = headerHeight
                    canScrollParent = false
                    canScrollChild = true
                }
            } else if parentOffset <= -parentScrollView.adjustedContentInset.top {
                parentScrollView.scrollToTop(forced: true, animated: false)
                canScrollChild = true
            } else if let childScrollView = contentView?.childScrollView {
                if childScrollView.contentOffset.y < -childScrollView.adjustedContentInset.top {
                    if childBounceTranslation > lastChildBounceTranslation {
                        parentScrollView.scrollToTop(forced: true, animated: false)
                        canScrollChild = true
                    } else {
                        canScrollChild = false
                    }
                } else {
                    canScrollChild = false
                }
            }
        }
        
        if canScrollParent {
            parentDidScrollSubject.send(parentScrollView)
        }
    }
    
    private func childScrollViewDidScroll(_ childScrollView: UIScrollView) {
        let parentOffset = parentScrollView.contentOffset.y
        let childOffset = childScrollView.contentOffset.y
        let headerHeight = headerView?.bounds.height ?? 0

        if shouldBounceParent {
            if !canScrollChild {
                childScrollView.scrollToTop(forced: true, animated: false)
            } else if childOffset <= -childScrollView.adjustedContentInset.top {
                canScrollChild = false
                canScrollParent = true
            }
        } else {
            if !canScrollChild {
                childScrollView.scrollToTop(forced: true, animated: false)
            } else if childOffset <= -childScrollView.adjustedContentInset.top  {
                if parentOffset <= -parentScrollView.adjustedContentInset.top  {
                    canScrollChild = true
                }
                canScrollParent = true
            } else if parentOffset > -parentScrollView.adjustedContentInset.top && parentOffset < headerHeight {
                canScrollChild = false
            }
        }
        
        if canScrollChild {
            childDidScrollSubject.send(childScrollView)
        }
    }
}


// MARK: - UIScrollViewDelegate(Parent)

extension NestedScrollingView: UIScrollViewDelegate {
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        guard scrollView === parentScrollView, scrollView.scrollsToTop else { return true }
        
        canScrollChild = false
        canScrollParent = true
        
        childScrollView?.scrollToTop(forced: true, animated: false)
        
        return true
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === parentScrollView else { return }
        
        isDragging = true
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView === parentScrollView else { return }
        
        isDragging = false
        
        guard automaticallyShowsHeader, let headerView else { return }
        
        let expectedOffset = targetContentOffset.pointee.y
        let headerHeight = headerView.bounds.height
        let criticalOffset: CGFloat
        
        switch criticalValueForAutomaticHeaderDisplay {
        case .fraction(var value):
            value = min(1, max(0, value))
            criticalOffset = headerHeight * value
        case .fixed(let value):
            criticalOffset = value
        }
        
        if expectedOffset <= criticalOffset {
            // scroll to top, display full header
            targetContentOffset.pointee.y = -scrollView.adjustedContentInset.top
        } else if expectedOffset > criticalOffset && expectedOffset < headerHeight  {
            // hide the header
            targetContentOffset.pointee.y = headerHeight
        }
    }
    
}