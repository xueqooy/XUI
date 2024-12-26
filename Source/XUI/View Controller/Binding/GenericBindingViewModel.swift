//
//  GenericBindingViewModel.swift
//  XUI
//
//  Created by xueqooy on 2024/11/20.
//

import Combine
import XKit

open class GenericBindingViewModel {
    public enum LoadStatus: Equatable {
        case idle
        case loading
        case success
        case failure(Error)

        public static func == (lhs: LoadStatus, rhs: LoadStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.loading, .loading):
                return true
            case (.success, .success):
                return true
            case (.failure, .failure):
                return false
            default:
                return false
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

    @EquatableState
    public var loadStatus: LoadStatus = .idle

    public var cancellables = Set<AnyCancellable>()

    public init() {}

    open func loadData() {}
}
