//
//  OrientationObserver.swift
//  XUI
//
//  Created by xueqooy on 2024/12/3.
//

import Combine
import UIKit
import XKit

public class OrientationObserver {
    private static var allObservers = WeakArray<OrientationObserver>()

    public var orientationPulisher: AnyPublisher<UIInterfaceOrientation, Never> {
        orientationSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private lazy var orientationSubject = CurrentValueSubject<UIInterfaceOrientation, Never>(orientation)

    public var orientation: UIInterfaceOrientation {
        UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
    }

    private var observation: AnyCancellable?

    public init() {
        Self.allObservers.append(self)

        startObserving()
    }

    deinit {
        stopObserving()
    }

    private func startObserving() {
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }

        observation = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                guard let self else { return }

                self.orientationSubject.send(self.orientation)
            }
    }

    private func stopObserving() {
        // End generating device orientation notifications if no observers is observing
        if UIDevice.current.isGeneratingDeviceOrientationNotifications {
            Self.allObservers.removeAll {
                $0 === self
            }

            if Self.allObservers.elements.isEmpty {
                UIDevice.current.endGeneratingDeviceOrientationNotifications()
            }
        }
    }
}
