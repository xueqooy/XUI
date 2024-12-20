//
//  UITextField+RichText.swift
//  XUI
//
//  Created by xueqooy on 2023/8/18.
//

import UIKit

public extension UITextField {
    var richText: RichText? {
        get { attributedText != nil ? RichText(attributedText!) : nil }
        set { attributedText = newValue?.attributedString }
    }

    var richPlaceholder: RichText? {
        get { attributedPlaceholder != nil ? RichText(attributedPlaceholder!) : nil }
        set { attributedPlaceholder = newValue?.attributedString }
    }
}
