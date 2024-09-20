//
//  MessageSending.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/13.
//

import Foundation

public protocol MessageSending {
    func sendMessage(_ output: MessageInputBarOutput) async -> Bool
}
