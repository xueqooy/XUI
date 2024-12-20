//
//  TextInput.swift
//  XUI
//
//  Created by xueqooy on 2023/3/10.
//

import Combine
import CombineCocoa
import UIKit

/// Text input view protocol, both UITextField and TextView follow this protocol
public protocol TextInput: UIView, TextStyleConfigurable, UITextInputTraits {
    var content: String? { set get }
    var richContent: RichText? { set get }
    var placeholder: String? { set get }

    var editingDidBeginPublisher: AnyPublisher<Void, Never> { get }
    var editingChangedPublisher: AnyPublisher<Void, Never> { get }
    var editingDidEndPublisher: AnyPublisher<Void, Never> { get }
    var editingDidEndOnExitPublisher: AnyPublisher<Void, Never>? { get }

    // UITextInputTraits

    var autocapitalizationType: UITextAutocapitalizationType { set get }
    var autocorrectionType: UITextAutocorrectionType { set get }
    var spellCheckingType: UITextSpellCheckingType { set get }
    var smartQuotesType: UITextSmartQuotesType { set get }
    var smartDashesType: UITextSmartDashesType { set get }
    var smartInsertDeleteType: UITextSmartInsertDeleteType { set get }
    var keyboardType: UIKeyboardType { set get }
    var keyboardAppearance: UIKeyboardAppearance { set get }
    var returnKeyType: UIReturnKeyType { set get }
    var enablesReturnKeyAutomatically: Bool { set get }
    var isSecureTextEntry: Bool { set get }
    var textContentType: UITextContentType! { set get }
    var passwordRules: UITextInputPasswordRules? { set get }
}

// MARK: - Extensions

extension UITextField: TextInput {
    public var content: String? {
        get {
            text
        }
        set {
            let oldValue = content
            text = newValue
            if oldValue != newValue {
                // UITextField does not respond to programmed text changes, manually trigger it
                sendActions(for: .editingChanged)
            }
        }
    }

    public var richContent: RichText? {
        get {
            richText
        }
        set {
            let oldValue = richContent
            richText = newValue
            if oldValue != newValue {
                // UITextField does not respond to programmed text changes, manually trigger it
                sendActions(for: .editingChanged)
            }
        }
    }

    public var editingDidBeginPublisher: AnyPublisher<Void, Never> {
        controlEventPublisher(for: .editingDidBegin)
    }

    public var editingChangedPublisher: AnyPublisher<Void, Never> {
        controlEventPublisher(for: .editingChanged)
    }

    public var editingDidEndPublisher: AnyPublisher<Void, Never> {
        controlEventPublisher(for: .editingDidEnd)
    }

    public var editingDidEndOnExitPublisher: AnyPublisher<Void, Never>? {
        controlEventPublisher(for: .editingDidEndOnExit)
    }
}

extension TextView: TextInput {
    public var content: String? {
        get {
            text
        }
        set {
            let oldValue = content
            text = newValue
            if oldValue != newValue {
                // TextView does not respond to programmed text changes, manually trigger it
                sendEditingChanged()
            }
        }
    }

    public var richContent: RichText? {
        get {
            richText
        }
        set {
            let oldValue = richContent
            richText = newValue
            if oldValue != newValue {
                // TextView does not respond to programmed text changes, manually trigger it
                sendEditingChanged()
            }
        }
    }

    public var editingDidEndOnExitPublisher: AnyPublisher<Void, Never>? {
        nil
    }
}
