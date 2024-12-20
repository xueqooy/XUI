//
//  Editable.swift
//  XUI
//
//  Created by xueqooy on 2023/10/24.
//

import Combine
import UIKit
import XKit

/// A protocol for controlling editing
public protocol Editable {
    var editableResponder: UIResponder? { get }
    func startEditing()
    func endEditing()
}

private let viewStateCancellableAssociation = Association<AnyCancellable>()

/// When the UIViewController conforms this protocol, it defaults to controlling the editing of the `MessageInputBar` that as inputAccessoryView of the UIViewController.
public extension Editable where Self: UIViewController {
    var editableResponder: UIResponder? {
        if let messageInputBarHostingView = view as? MessageInputBarHostingView {
            return messageInputBarHostingView
        }

        return nil
    }

    func startEditing() {
        guard let editableResponder = editableResponder else {
            return
        }

        if viewState == .didAppear {
            _ = editableResponder.becomeFirstResponder()
        } else if viewState != .willDisappear && viewState != .didDisappear {
            viewStateCancellableAssociation[self] = viewStatePublisher
                .filter { $0 == .didAppear }
                .first()
                .sink { _ in
                    _ = editableResponder.becomeFirstResponder()
                } receiveValue: { _ in }
        }
    }

    func endEditing() {
        guard let editableResponder = editableResponder else {
            return
        }

        _ = editableResponder.resignFirstResponder()
    }
}
