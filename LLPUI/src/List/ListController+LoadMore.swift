//
//  ListController+LoadMore.swift
//  LLPUI
//
//  Created by xueqooy on 2023/9/11.
//

import UIKit
import LLPUtils
import Combine

/// - Note: Ensure that `listView.alwaysBounceHorizontal` is true
public extension ListController {
    
    private struct Associations {
        static let canLoadMore = Association<Bool>()
        static let isLoadingMore = Association<Bool>()
        static var loadMoreHandler = Association<Handler>(wrap: .retain)
        static var isLoadingMoreSubject = Association<CurrentValueSubject<Bool, Never>>()
    }
    
    var canLoadMore: Bool {
        set {
            Associations.canLoadMore[self] = newValue
        }
        get {
            Associations.canLoadMore[self] ?? false
        }
    }
    
    var loadMoreHandler: (Handler)? {
        set {
            Associations.loadMoreHandler[self] = newValue
        }
        get {
            Associations.loadMoreHandler[self]
        }
    }
    
    private(set) var isLoadingMore: Bool {
        set {
            guard isLoadingMore != newValue else {
                return
            }
            
            Associations.isLoadingMore[self] = newValue
            
            isLoadingMoreSubject.send(newValue)
            
            listAdapter.performUpdates(animated: true)
        }
        get {
            Associations.isLoadingMore[self] ?? false
        }
    }
    
    var isLoadingMorePublisher: AnyPublisher<Bool, Never> {
        isLoadingMoreSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    private var isLoadingMoreSubject: CurrentValueSubject<Bool, Never> {
        var subject = Associations.isLoadingMoreSubject[self]
        if subject == nil {
            subject = .init(isLoadingMore)
            Associations.isLoadingMoreSubject[self] = subject
        }
        return subject!
    }
    
    func beginLoadingMore() {
        guard canLoadMore && !isLoadingMore else {
            return
        }
        
        isLoadingMore = true
        
        loadMoreHandler?(self)
    }
    
    func endLoadingMore() {
        isLoadingMore = false
    }
}


extension ListController: UIScrollViewDelegate {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let _ = loadMoreHandler, canLoadMore else {
            return
        }
        
        let distance: CGFloat
        
        if scrollDirection == .vertical {
            distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
            
        } else {
            distance = scrollView.contentSize.width - (targetContentOffset.pointee.x + scrollView.bounds.width)
        }
        
        if distance < 200 {
            beginLoadingMore()
        }
    }
}
