//
//  BindingListViewModel.swift
//  LLPUI
//
//  Created by xueqooy on 2024/10/19.
//

import Foundation
import IGListDiffKit
import Combine
import LLPUtils

open class BindingListViewModel: GenericBindingViewModel {
    
    @State
    public var objects: [ListDiffable] = []
    
    open var canLoadMorePublisher: AnyPublisher<Bool, Never>? { nil }
    
    open func loadMoreData() {
    }
}
