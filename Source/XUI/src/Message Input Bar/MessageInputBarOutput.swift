//
//  MessageInputBarOutput.swift
//  XUI
//
//  Created by xueqooy on 2023/10/13.
//

import Foundation

public struct MessageInputBarOutput {
    public let text: String?
    public let contents: [Any]
    
    public init(text: String?, contents: [Any]) {
        self.text = text
        self.contents = contents
    }
}
