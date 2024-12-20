//
//  SingleSelectionGroup.swift
//  XUI
//
//  Created by xueqooy on 2023/3/8.
//

import Combine
import Foundation
import ObjectiveC.runtime
import XKit

public protocol Selectable {
    var isSelected: Bool { set get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
}

public class SingleSelectionGroup {
    public var selectionPublisher: AnyPublisher<Selectable & AnyObject, Never> {
        selectionSubject.eraseToAnyPublisher()
    }

    private let selectionSubject = PassthroughSubject<Selectable & AnyObject, Never>()

    func notify(_ selectable: Selectable & AnyObject) {
        if selectable.isSelected {
            selectionSubject.send(selectable)
        }
    }

    public init() {}
}

private enum AssociatedKey {
    static var cancellables = "SingleSelectionGroup.cancellables"
    static var singleSelectionGroup = "SingleSelectionGroup.singleSelectionGroup"
}

public extension Selectable where Self: AnyObject {
    private var cancellables: [AnyCancellable]? {
        set {
            withUnsafePointer(to: &AssociatedKey.cancellables) {
                objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            withUnsafePointer(to: &AssociatedKey.cancellables) {
                objc_getAssociatedObject(self, $0) as? [AnyCancellable]
            }
        }
    }

    var singleSelectionGroup: SingleSelectionGroup? {
        set {
            if singleSelectionGroup === newValue {
                return
            }

            withUnsafePointer(to: &AssociatedKey.singleSelectionGroup) {
                objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }

            cancellables = nil
            if let singleSelectionGroup = newValue {
                var cancellables = [AnyCancellable]()

                singleSelectionGroup.selectionPublisher
                    .receive(on: RunLoop.main)
                    .sink { [weak self] selectable in
                        guard var self = self else {
                            return
                        }

                        if selectable.isSelected && selectable !== self {
                            self.isSelected = false
                        }
                    }
                    .store(in: &cancellables)

                isSelectedPublisher
                    .sink { [weak self] _ in
                        guard let self = self else {
                            return
                        }

                        singleSelectionGroup.notify(self)
                    }
                    .store(in: &cancellables)

                singleSelectionGroup.notify(self)

                self.cancellables = cancellables
            }
        }
        get {
            withUnsafePointer(to: &AssociatedKey.singleSelectionGroup) {
                objc_getAssociatedObject(self, $0) as? SingleSelectionGroup
            }
        }
    }
}
