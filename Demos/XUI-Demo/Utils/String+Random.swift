//
//  String+RandomText.swift
//  XUI_Example
//
//  Created by xueqooy on 2024/1/4.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

extension String {
    static func random(_ range: Range<Int> = 0..<100) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString = String(range.map { _ in
            letters.randomElement()!
        })
        return randomString
    }
}
