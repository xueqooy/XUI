//
//  NestedScrollingConfiguration.swift
//  Pods
//
//  Created by xueqooy on 2024/11/21.
//

import UIKit

open class NestedScrollingConfiguration {
    public let headerView: NestedScrollingHeader?
    public let isRefreshEnabled: Bool
    public let stickyHeader: Bool

    public init(headerView: NestedScrollingHeader? = nil, isRefreshEnabled: Bool = true, stickyHeader: Bool = false) {
        self.headerView = headerView
        self.isRefreshEnabled = isRefreshEnabled
        self.stickyHeader = stickyHeader
    }
        
    open func didAdd(to viewController: UIViewController) {
    }
    
    open func parentContentOffsetDidChange(_ offset: CGFloat) {
    }
}
