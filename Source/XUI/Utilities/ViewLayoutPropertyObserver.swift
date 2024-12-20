//
//  ViewLayoutPropertyObserver.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/10/21.
//

import Combine
import UIKit
import XKit

public class ViewLayoutPropertyObserver {
    public struct Properties: OptionSet {
        public static let frame: Properties = .init(rawValue: 1)
        public static let bounds: Properties = .init(rawValue: 1 << 1)
        public static let center: Properties = .init(rawValue: 1 << 2)
        public static let transform: Properties = .init(rawValue: 1 << 3)

        public static let all: Properties = [.frame, .center, .bounds, .transform]

        public let rawValue: Int8

        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }
    }

    private struct ObservationValue: Equatable {
        private(set) var frame: CGRect?
        private(set) var bounds: CGRect?
        private(set) var center: CGPoint?
        private(set) var transform: CGAffineTransform?

        init(view: UIView, properties: Properties) {
            if properties.contains(.frame) {
                frame = view.frame
            }

            if properties.contains(.bounds) {
                bounds = view.bounds
            }

            if properties.contains(.center) {
                center = view.center
            }

            if properties.contains(.transform) {
                transform = view.transform
            }
        }
    }

    /// The view that owns the observer
    public private(set) weak var view: UIView?

    public var propertyDidChangePublisher: AnyPublisher<ViewLayoutPropertyObserver, Never> {
        propertyDidChangeSubject
            .removeDuplicates()
            .compactMap { [weak self] _ in
                self
            }
            .eraseToAnyPublisher()
    }

    private var propertyDidChangeSubject = PassthroughSubject<ObservationValue, Never>()

    private var observations = [NSKeyValueObservation]()

    private let properties: Properties

    public init(properties: Properties = .all) {
        Asserts.failure("At least one property should be observed", condition: !properties.isEmpty)

        self.properties = properties
    }

    deinit {
        removeFromView()
    }

    public func addToView(_ view: UIView) {
        removeFromView()

        self.view = view

        weak var weakself = self

        func handleChange<Value>(_ view: UIView, change: NSKeyValueObservedChange<Value>) {
            guard let self = weakself, !change.isPrior, change.kind == .setting else {
                return
            }

            let value = ObservationValue(view: view, properties: self.properties)

            self.propertyDidChangeSubject.send(value)
        }

        if properties.contains(.frame) {
            observations.append(view.observe(\.frame, changeHandler: handleChange))
        }

        if properties.contains(.bounds) {
            observations.append(view.observe(\.bounds, changeHandler: handleChange))
        }

        if properties.contains(.center) {
            observations.append(view.observe(\.center, changeHandler: handleChange))
        }

        if properties.contains(.transform) {
            observations.append(view.observe(\.transform, changeHandler: handleChange))
        }
    }

    public func removeFromView() {
        view = nil

        observations.removeAll { observation in
            observation.invalidate()
            return true
        }
    }
}
