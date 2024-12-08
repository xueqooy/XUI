//
//  NestedScrollingConfiguration.swift
//  Pods
//
//  Created by xueqooy on 2024/11/21.
//

import UIKit

open class NestedScrollingConfiguration {
    public typealias HeaderStickyMode = NestedScrollingView.HeaderStickyMode
    public typealias CriticalValue = NestedScrollingView.CriticalValue
    
    public let headerView: NestedScrollingHeader?
    public let isRefreshEnabled: Bool
    public let headerStickyMode: HeaderStickyMode
    public let criticalValueForAutomaticHeaderDisplay: CriticalValue

    public init(headerView: NestedScrollingHeader? = nil, isRefreshEnabled: Bool = true, headerStickyMode: HeaderStickyMode = .never, criticalValueForAutomaticHeaderDisplay: CriticalValue = .fraction(0.5)) {
        self.headerView = headerView
        self.isRefreshEnabled = isRefreshEnabled
        self.headerStickyMode = headerStickyMode
        self.criticalValueForAutomaticHeaderDisplay = criticalValueForAutomaticHeaderDisplay
    }
        
    open func didAdd(to viewController: UIViewController) {
    }
    
    open func parentContentOffsetDidChange(_ offset: CGFloat) {
    }
}
