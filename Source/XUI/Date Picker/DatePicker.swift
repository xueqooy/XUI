//
//  DatePicker.swift
//  XUI
//
//  Created by xueqooy on 2024/7/4.
//

import UIKit

public class DatePicker: ContentPresenter {
    override public var contentView: UIView? {
        var scheduleDate: Date? = date

        let applyButton = Button(designStyle: .primary, title: Strings.apply, width: 270) { _ in
            self.dateDidSelectHandler(scheduleDate)
            self.deactivate()
        }
        applyButton.isEnabled = scheduleDate != nil

        let scheduleDateField = DatePickerField(date: scheduleDate, minimumDate: minimumDate, maximumDate: maximumDate, placeholder: placeholder) { [weak applyButton] in

            scheduleDate = $0

            applyButton?.isEnabled = scheduleDate != nil
        }

        let cancelButton = Button(designStyle: .secondary, title: Strings.cancel, width: 270) { _ in

            self.deactivate()
        }

        let formView = FormView(contentScrollingBehavior: .disabled)
        formView.contentInset = .nondirectional(top: (title ?? "").isEmpty ? .XUI.spacing5 : 0, left: 0, bottom: presentationStyle == .popup ? .XUI.spacing5 : 0, right: 0)
        formView.populate {
            if let title, !title.isEmpty {
                FormRow(UILabel(text: title, textStyleConfiguration: .init(textColor: Colors.title, font: Fonts.body1Bold, textAlignment: .center)))
                    .settingCustomSpacingAfter(.XUI.spacing10)
            }

            FormRow(scheduleDateField)

            FormSpacer(.XUI.spacing10 * (presentationStyle == .popover ? 1 : 3), huggingPriority: .fittingSizeLevel)

            FormRow(applyButton, alignment: .center)
                .settingCustomSpacingAfter(.XUI.spacing3)

            FormRow(cancelButton, alignment: .center)
        }

        return formView
    }

    private let date: Date?
    private let minimumDate: Date?
    private let maximumDate: Date?
    private let title: String?
    private let placeholder: String?
    private let dateDidSelectHandler: (Date?) -> Void

    public init(date: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, title: String? = nil, placeholder: String? = nil, presentationStyle: PresentationStyle = .popup, presentingViewController: UIViewController? = nil, sourceView: UIView? = nil, sourceRect: CGRect? = nil, dateDidSelectHandler: @escaping (Date?) -> Void) {
        self.date = date
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.title = title
        self.placeholder = placeholder
        self.dateDidSelectHandler = dateDidSelectHandler

        super.init(presentationStyle: presentationStyle)

        self.presentingViewController = presentingViewController
        self.sourceView = sourceView
        self.sourceRect = sourceRect
    }

    override public var preferredContentSize: CGSize? {
        CGSize(width: 350, height: 0)
    }
}
