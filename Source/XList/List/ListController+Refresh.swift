//
//  ListController+Refresh.swift
//  XUI
//
//  Created by xueqooy on 2023/9/11.
//

import Combine
import UIKit
import XKit
import XUI

/// Provide dropdown refresh capability
/// - Note: Ensure that `listView.alwaysBounceVertical` is true
public extension ListController {
    private enum Associations {
        static let canRefresh = Association<Bool>()
        static let refreshHandler = Association<Handler>()
        static var refreshControl = Association<RefreshControl>()
        static var isRefreshingSubject = Association<CurrentValueSubject<Bool, Never>>()
    }

    var canRefresh: Bool {
        set {
            guard canRefresh != newValue else {
                return
            }

            if newValue {
                listView.refreshControl = refreshControl
            } else {
                listView.refreshControl = nil
            }

            Associations.canRefresh[self] = newValue
        }
        get {
            Associations.canRefresh[self] ?? false
        }
    }

    var refreshHandler: ((ListController) -> Void)? {
        set {
            Associations.refreshHandler[self] = newValue
        }
        get {
            Associations.refreshHandler[self]
        }
    }

    var isRefreshing: Bool {
        refreshControl.isRefreshing
    }

    var isRefreshingPublisher: AnyPublisher<Bool, Never> {
        isRefreshingSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private var isRefreshingSubject: CurrentValueSubject<Bool, Never> {
        var subject = Associations.isRefreshingSubject[self]
        if subject == nil {
            subject = .init(isRefreshing)
            Associations.isRefreshingSubject[self] = subject
        }
        return subject!
    }

    private var refreshControl: RefreshControl {
        var refreshControl = Associations.refreshControl[self]
        if refreshControl == nil {
            refreshControl = RefreshControl()
            refreshControl?.addTarget(self, action: #selector(Self.refreshControlValueChanged), for: .valueChanged)

            Associations.refreshControl[self] = refreshControl
        }
        return refreshControl!
    }

    func beginRefreshing() {
        guard canRefresh, !isRefreshing else {
            return
        }

        refreshControl.beginRefreshing()
        isRefreshingSubject.send(true)
        refreshHandler?(self)
    }

    func endRefreshing() {
        refreshControl.endRefreshing()
        isRefreshingSubject.send(false)
    }

    @objc private func refreshControlValueChanged() {
        if refreshControl.isRefreshing {
            isRefreshingSubject.send(true)
            refreshHandler?(self)
        } else {
            isRefreshingSubject.send(false)
        }
    }
}
