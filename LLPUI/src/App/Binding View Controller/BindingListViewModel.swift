//
//  BindingListViewModel.swift
//  LLPUI
//
//  Created by xueqooy on 2024/10/19.
//

import Foundation
import IGListDiffKit
import Combine

public enum BindingListLoadStatus {
    case idle
    case loading
    case success
    case failure(Error)
    
    public enum SimpleStatus: Equatable{
        case idle
        case loading
        case success
        case failure
    }
    
    public var simple: SimpleStatus {
        switch self {
        case .idle:
            return .idle
        case .loading:
            return .loading
        case .success:
            return .success
        case .failure(let error):
            return .failure
        }
    }
    
    public var isIdle: Bool {
        if case .idle = self {
            return true
        }
        
        return false
    }
    
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        
        return false
    }
    
    public var isSuccess: Bool {
        if case .success = self {
            return true
        }
        
        return false
    }
    
    public var isFailure: Bool {
        if case .failure = self {
            return true
        }
        
        return false
    }
}

public protocol BindingListViewModel {
    
    var objectsPublisher: AnyPublisher<[ListDiffable], Never> { get }
    var loadStatusPublisher: AnyPublisher<BindingListLoadStatus, Never>? { get }
    var canLoadMorePublisher: AnyPublisher<Bool, Never>? { get }
    
    var loadStatus: BindingListLoadStatus { get }

    func reloadData()
    func loadMoreData()
}

public extension BindingListViewModel {
    
    var canLoadMorePublisher: AnyPublisher<Bool, Never>? { nil }
    func loadMoreData() {}
}
