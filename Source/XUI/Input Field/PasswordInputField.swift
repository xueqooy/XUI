//
//  PasswordInputField.swift
//  XUI
//
//  Created by xueqooy on 2023/2/23.
//

import Combine
import SnapKit
import UIKit

/// A password input field with visual button
public class PasswordInputField: InputField {
    private enum Constants {
        static let visibilityButtonWidth = 20
    }

    override public var isSecureTextEntry: Bool {
        set {
            if textInput.isSecureTextEntry != newValue {
                toggleVisibility()
            }
        }
        get {
            textInput.isSecureTextEntry
        }
    }

    public var isStrengthIndicatorEnabled: Bool = false {
        didSet {
            if oldValue == isStrengthIndicatorEnabled {
                return
            }

            if isStrengthIndicatorEnabled {
                if let boxStackViewIndex = verticalStackView.arrangedSubviews.firstIndex(of: boxStackView) {
                    verticalStackView.insertArrangedSubview(passwordStrengthIndicatorView, at: boxStackViewIndex + 1)
                } else {
                    verticalStackView.addArrangedSubview(passwordStrengthIndicatorView)
                }
                updateStrengthIndicator()
            } else {
                passwordStrengthIndicatorView.removeFromSuperview()
            }
        }
    }

    public typealias PasswordStrengthLevel = PasswordStrengthIndicatorView.Level
    public var strengthLevel: PasswordStrengthLevel = .weak {
        didSet {
            guard strengthLevel != oldValue else {
                return
            }

            passwordStrengthIndicatorView.level = strengthLevel
        }
    }

    override public var text: String? {
        didSet {
            if oldValue == text {
                return
            }

            updateStrengthIndicator()
        }
    }

    private lazy var visibilityButton: Button = {
        let button = Button { [weak self] _ in
            self?.toggleVisibility()
        }
        return button
    }()

    private lazy var passwordStrengthIndicatorView = PasswordStrengthIndicatorView(level: .weak)

    private var cancellable: AnyCancellable?

    override public init() {
        super.init()

        initialize()
    }

    private func initialize() {
        textInput.keyboardType = .asciiCapable
        textInput.isSecureTextEntry = true

        boxStackView.addArrangedSubview(visibilityButton)
        visibilityButton.snp.makeConstraints { make in
            make.width.equalTo(Constants.visibilityButtonWidth)
        }

        updateVisibilityButtonImage()

        cancellable = textInput.editingChangedPublisher.sink { [weak self] _ in
            guard let self = self else { return }

            self.updateStrengthIndicator()
        }
    }

    override public func stateDidChange() {
        super.stateDidChange()

        visibilityButton.configuration.foregroundColor = fieldState == .disabled ? Colors.disabledText : Colors.teal

        updateStrengthIndicator()
    }

    private func updateStrengthIndicator() {
        if !isStrengthIndicatorEnabled {
            return
        }

        if fieldState != .active {
            passwordStrengthIndicatorView.isHidden = true
        } else {
            let text = text ?? ""
            passwordStrengthIndicatorView.isHidden = text.isEmpty == true
            if !text.isEmpty {
                passwordStrengthIndicatorView.level = strengthLevel
            }
        }
    }

    private func toggleVisibility() {
        textInput.isSecureTextEntry.toggle()

        updateVisibilityButtonImage()
    }

    private func updateVisibilityButtonImage() {
        visibilityButton.configuration.image = textInput.isSecureTextEntry ? Icons.visibilityOff : Icons.visibilityOn
    }
}
