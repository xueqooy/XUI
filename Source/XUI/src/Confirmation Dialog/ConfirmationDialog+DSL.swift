//
//  ConfirmationDialog+DSL.swift
//  XUI
//
//  Created by xueqooy on 2023/10/17.
//

import XKit
import Combine

public func CDInput(label: String? = nil, placeholder: String? = nil, isMultiline: Bool = false, maximumTextLength: Int = .max, textSubscriber: any Subscriber<String, Never>) -> ConfirmationDialog.Element {
    .input(label: label, placeholder: placeholder, isMultiline: isMultiline, maximumTextLength: maximumTextLength, textSubscriber: textSubscriber)
}

public func CDButton(title: String, role: ConfirmationDialog.ButtonRole = .primary, enabler: AnyPublisher<Bool, Never>? = nil, keepsDialogPresented: Bool = false, handler: ((ConfirmationDialogToken) -> Void)? = nil) -> ConfirmationDialog.Element {
    .button(title: title, role: role, enabler: enabler, keepsDialogPresented: keepsDialogPresented, handler: handler)
}

public func CDCustomView(_ customView: UIView, height: CGFloat? = nil, alignment: ConfirmationDialog.CustomViewAlignment = .fill, insets: UIEdgeInsets? = nil) -> ConfirmationDialog.Element {
    .customView(customView, height: height, alignment: alignment, insets: insets)
}

public extension ConfirmationDialog {

    convenience init(popupConfiguration: PopupController.Configuration = ConfirmationDialog.defaultPopupConfiguration, image: UIImage? = nil, imageSize: CGSize? = nil, title: String? = nil, detailText: String? = nil, detailRichText: RichText? = nil, @ArrayBuilder<Element> elements: () -> [Element]) {
        self.init(popupConfiguration: popupConfiguration, image: image, imageSize: imageSize, title: title, detailText: detailText, detailRichText: detailRichText, elements: elements())
    }
}
