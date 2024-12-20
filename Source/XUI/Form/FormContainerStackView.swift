//
//  FormContainerStackView.swift
//  XUI
//
//  Created by xueqooy on 2023/3/10.
//

import UIKit
import XKit

class FormContainerStackView: VStackView {
    /// Whether has a arranged subview showing except for spacer, only available after `startTrackcingContent()` called
    @EquatableState
    private(set) var hasVisibleContent: Bool?

    private var shouldCheckContent = false

    init() {
        super.init(frame: .zero)

        isLayoutMarginsRelativeArrangement = true
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        maybeCheckContent()
    }

    func startTrackcingContent() {
        shouldCheckContent = true

        maybeCheckContent()
    }

    func stopTrackingContent() {
        shouldCheckContent = false
        hasVisibleContent = nil
    }

    private func maybeCheckContent() {
        guard shouldCheckContent else { return }

        var hasVisibleContent = false

        // Except for spacer, any arranged subview whose isHidden is false is considered to have visible content.
        for arrangedSubview in arrangedSubviews {
            guard !(arrangedSubview is FormSpacerView) else {
                continue
            }

            if !arrangedSubview.isHidden {
                hasVisibleContent = true
                break
            }
        }

        self.hasVisibleContent = hasVisibleContent
    }
}
