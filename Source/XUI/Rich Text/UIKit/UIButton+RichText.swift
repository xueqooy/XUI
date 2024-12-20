//
//  UIButton+RichText.swift
//  XUI
//
//  Created by xueqooy on 2023/8/18.
//

import UIKit

public extension UIButton {
    func setRichTitle(_ title: RichText?, for state: UIControl.State) {
        setAttributedTitle(title?.attributedString, for: state)
    }

    func richTitle(for state: UIControl.State) -> RichText? {
        if let attributedTitle = attributedTitle(for: state) {
            return RichText(attributedTitle)
        } else {
            return nil
        }
    }
}
