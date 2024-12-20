//
//  MessageInputPlugin.swift
//  XUI
//
//  Created by xueqooy on 2023/10/9.
//

import Combine
import Foundation
import XKit

public protocol MessageInputPlugin: StateObservableObject {
    var isUserInteractionEnabled: Bool { set get }

    /// Contents to be sent
    var sendableContents: [Any] { get }

    /// Should the sending of messages be blocked
    var shouldBlockSending: Bool { get }

    func didAdd(to inputBar: MessageInputBar)

    /// Reload the state of `MessageInputPlugin`
    func reloadData()

    /// Remove any content that the `MessageInputPlugin` is managing
    func invalidate()

    /// Handle the input of data types that an `MessageInputPlugin` manages
    func handleInput(_ input: Any) -> Bool
}
