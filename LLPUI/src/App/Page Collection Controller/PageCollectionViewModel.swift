//
//  PageCollectionViewModel.swift
//  LLPUI
//
//  Created by xueqooy on 2024/10/19.
//

import Foundation
import LLPUtils

open class PageCollectionViewModel {
    
    public enum Status {
        case idle
        case loading
        case loaded
        case failed(Error)
    }
    
    public let title: String?
    
    public init(title: String? = nil) {
        self.title = title
    }
    
    @State
    public var pages = [Page]()
    
    @State
    public var status: Status = .idle
        
    open func loadData() {
    }
}
