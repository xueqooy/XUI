//
//  ActionSheet+DSL.swift
//  XUI
//
//  Created by xueqooy on 2023/10/12.
//

import UIKit
import XKit

public func ASButton(title: String? = nil, richTitle: RichText? = nil, image: UIImage? = nil, keepsSheetPresented: Bool = false, handler: (() -> Void)? = nil) -> ActionSheet.Element {
    .button(title: title, richTitle: richTitle, image: image, keepsSheetPresented: keepsSheetPresented, handler: handler)
}

public func ASLabel(_ text: String? = nil, _ richText: RichText? = nil) -> ActionSheet.Element {
    .label(text, richText)
}

public func ASSeparator() -> ActionSheet.Element {
    .separator
}

public func ASCustomView(_ customView: UIView, height: CGFloat? = nil, alignment: ActionSheet.CustomViewAlignment = .fill, insets: UIEdgeInsets? = nil) -> ActionSheet.Element {
    .customView(customView, height: height, alignment: alignment, insets: insets)
}

public func ASSpacer(_ spacing: CGFloat = .XUI.spacing3) -> ActionSheet.Element {
    .customView(UIView(), height: spacing)
}

public extension ActionSheet {
    convenience init(title: String? = nil, @ArrayBuilder<Element> elements: () -> [Element]) {
        self.init(title: title, elements: elements())
    }
}
