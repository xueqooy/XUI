//
//  UIView+DockedKeyboardLayoutGuide.swift
//  XUI
//
//  Created by xueqooy on 2023/8/1.
//

import Combine
import UIKit

extension UIView {
    private static let dockedKeyboardLayoutGuideIdentifier: String = "dockedKeyboardLayoutGuideIdentifier"
    private static let dockedKeyboardLayoutGuideIgnoringSafeAreaIdentifier: String = "dockedKeyboardLayoutGuideIgnoringSafeAreaIdentifier"

    /// A layout guide representing the inset for the docked keyboard.
    /// Use this layout guide’s top anchor to create constraints pinning to the top of the docked keyboard or the bottom of safe area.
    public var dockedKeyboardLayoutGuide: UILayoutGuide {
        if let existing = layoutGuides.first(where: { $0.identifier == Self.dockedKeyboardLayoutGuideIdentifier }) {
            return existing
        }
        let new = DockedKeyboardLayoutGuide(respectsSafeArea: true)
        new.identifier = Self.dockedKeyboardLayoutGuideIdentifier
        addLayoutGuide(new)
        new.setUp()
        return new
    }

    /// A layout guide representing the inset for the docked keyboard.
    /// Use this layout guide’s top anchor to create constraints pinning to the top of the docked keyboard or the bottom.
    public var dockedKeyboardLayoutGuideIgnoringSafeArea: UILayoutGuide {
        if let existing = layoutGuides.first(where: { $0.identifier == Self.dockedKeyboardLayoutGuideIgnoringSafeAreaIdentifier }) {
            return existing
        }
        let new = DockedKeyboardLayoutGuide(respectsSafeArea: false)
        new.identifier = Self.dockedKeyboardLayoutGuideIgnoringSafeAreaIdentifier
        addLayoutGuide(new)
        new.setUp()
        return new
    }
}

private class DockedKeyboardLayoutGuide: UILayoutGuide {
    private var heightConstraint: NSLayoutConstraint?

    private let keyboardManager = KeyboardManager()

    private var cancellable: AnyCancellable?

    private let respectsSafeArea: Bool

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(respectsSafeArea: Bool) {
        self.respectsSafeArea = respectsSafeArea

        super.init()

        cancellable = keyboardManager.didReceiveEventPublisher
            .filter { $0.0 == .willChangeFrame || $0.0 == .didHide }
            .sink { [weak self] _, info in
                guard let self = self else { return }
                self.update(with: info)
            }
    }

    func setUp() {
        guard let view = owningView else { return }

        let height = KeyboardManager.distanceFromMinYToBottom(of: view, respectsSafeArea: respectsSafeArea)

        heightConstraint = heightAnchor.constraint(equalToConstant: max(height, 0))

        NSLayoutConstraint.activate(
            [
                heightConstraint!,
                leftAnchor.constraint(equalTo: view.leftAnchor),
                rightAnchor.constraint(equalTo: view.rightAnchor),
                bottomAnchor.constraint(equalTo: respectsSafeArea ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor),
            ]
        )
    }

    private func update(with keyboardInfo: KeyboardInfo) {
        guard let view = owningView else { return }

        let height = KeyboardManager.distanceFromMinYToBottom(of: view, keyboardRect: keyboardInfo.endFrame, respectsSafeArea: respectsSafeArea)

        heightConstraint?.constant = max(height, 0)

        if let duration = keyboardInfo.animationDuration, duration > 0 {
            view.layoutIfNeeded()
        }
    }
}
