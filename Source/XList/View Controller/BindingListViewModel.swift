//
//  BindingListViewModel.swift
//  XUI
//
//  Created by xueqooy on 2024/10/19.
//

import Combine
import Foundation
import IGListDiffKit
import XKit
import XUI

open class BindingListViewModel: GenericBindingViewModel {
    @State
    public var objects: [ListDiffable] = []

    open var canLoadMorePublisher: AnyPublisher<Bool, Never>? { nil }

    open func loadMoreData() {}
}
