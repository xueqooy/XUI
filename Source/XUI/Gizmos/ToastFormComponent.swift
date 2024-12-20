//
//  ToastFormComponent.swift
//  XUI
//
//  Created by xueqooy on 2023/5/8.
//

import UIKit

public class ToastFormComponent: Configurable {
    public var configuration: ToastView.Configuration {
        get {
            toastView.configuration
        }
        set {
            toastView.configuration = newValue

            if !newValue.isEmptyMessage {
                toastView.triggerFeedback()
                if newValue.style == .error {
                    toastView.layer.animateShake()
                }

                if reservesSpaceForEmptyMessage {
                    toastView.isHidden = false
                } else {
                    toastItem.isHidden = false
                }
            } else {
                if reservesSpaceForEmptyMessage {
                    toastView.isHidden = true
                } else {
                    toastItem.isHidden = true
                }
            }
        }
    }

    public let reservesSpaceForEmptyMessage: Bool

    private let toastView: ToastView
    private let toastItem: FormItem

    public init(configuration: ToastView.Configuration, reservesSpaceForEmptyMessage: Bool = false) {
        self.reservesSpaceForEmptyMessage = reservesSpaceForEmptyMessage
        toastView = ToastView(configuration: configuration)
        toastItem = FormRow(toastView)

        if reservesSpaceForEmptyMessage {
            toastView.isHidden = configuration.isEmptyMessage
        } else {
            toastItem.isHidden = configuration.isEmptyMessage
        }
    }
}

extension ToastFormComponent: FormComponent {
    public func asFormItems() -> [FormItem] {
        [
            toastItem,
        ]
    }
}
