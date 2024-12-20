//
//  UITextInput+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2023/5/24.
//

import UIKit

public extension UITextInput {
    func convertTextRange(from range: NSRange) -> UITextRange? {
        let beginning = beginningOfDocument

        guard let startPosition = position(from: beginning, offset: range.location), let endPosition = position(from: beginning, offset: NSMaxRange(range)) else {
            return nil
        }

        return textRange(from: startPosition, to: endPosition)
    }
}
