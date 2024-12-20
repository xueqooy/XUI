//
//  SearchInputField.swift
//  XUI
//
//  Created by xueqooy on 2023/3/10.
//

import Combine
import UIKit

public class SearchInputField: InputField {
    public typealias ActionHandler = (SearchInputField, Action) -> Void

    public enum Style {
        case `default`
        case large
    }

    public enum Action {
        case search
        case cancel
    }

    public let style: Style

    public var actionHandler: ActionHandler?

    override public var returnKeyType: UIReturnKeyType {
        set {}
        get { .search }
    }

    override public var text: String? {
        didSet {
            if oldValue == text {
                return
            }

            hasText = text?.isEmpty == false
        }
    }

    private var hasText: Bool = false {
        didSet {
            if oldValue == hasText {
                return
            }

            updateButtonImage()
        }
    }

    private lazy var button: Button = {
        let button = Button { [weak self] _ in
            guard let self else { return }

            if self.hasText {
                self.cancel()
            } else {
                self.search()
            }
        }
        return button
    }()

    private var editingChangedSubscription: AnyCancellable?

    public init(style: Style = .default) {
        self.style = style

        super.init()

        initialize()
    }

    public convenience init(style: Style = .default, label: String? = nil, placeholder: String? = nil, actionHandler: ActionHandler? = nil) {
        self.init(style: style)

        self.label = label
        self.placeholder = placeholder
        self.actionHandler = actionHandler
    }

    private func initialize() {
        textInput.returnKeyType = returnKeyType
        textInput.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically

        boxStackView.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        updateButtonImage()

        editingChangedSubscription = textInput.editingChangedPublisher.sink { [weak self] _ in
            guard let self else { return }

            self.hasText = self.text?.isEmpty == false
        }
    }

    override public func stateDidChange() {
        super.stateDidChange()

        button.configuration.foregroundColor = fieldState == .disabled ? Colors.disabledText : Colors.bodyText1
    }

    override public var defaultContentInset: Insets {
        switch style {
        case .default:
            super.defaultContentInset
        case .large:
            .directional(top: 0, leading: .XUI.spacing6, bottom: 0, trailing: .XUI.spacing6)
        }
    }

    override public var defaultContentHeight: CGFloat {
        switch style {
        case .default:
            super.defaultContentHeight
        case .large:
            72
        }
    }

    override public func defaultBackgroundConfiguration(forFieldState fieldState: Field.FieldState, validationState: Field.ValidationState) -> BackgroundConfiguration {
        var configuration = super.defaultBackgroundConfiguration(forFieldState: fieldState, validationState: validationState)

        if style == .large {
            configuration.cornerStyle = .capsule

            if fieldState == .normal {
                configuration.stroke.width = 0
            }
        }

        return configuration
    }

    private func search() {
        _ = resignFirstResponder()

        actionHandler?(self, .search)
    }

    private func cancel() {
        text = nil
        _ = resignFirstResponder()

        actionHandler?(self, .cancel)
    }

    private func updateButtonImage() {
        button.configuration.image = hasText ? Icons.xmarkSmall : Icons.search
    }

    public func textFieldShouldReturn(_: UITextField) -> Bool {
        search()

        return true
    }
}
