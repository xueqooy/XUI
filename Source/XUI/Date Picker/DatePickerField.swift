//
//  DatePickerField.swift
//  XUI
//
//  Created by xueqooy on 2024/6/28.
//

import Combine
import UIKit
import XKit

public class DatePickerField: Field {
    public var placeholder: String? {
        set {
            dateSelectField.placeholder = newValue
        }
        get {
            dateSelectField.placeholder
        }
    }

    @EquatableState
    public var date: Date? {
        didSet {
            guard date != oldValue else { return }

            dateChanged?(date)

            timePickerField.isHidden = date == nil

            guard !settingDateInternally else { return }

            let newDate = date

            updatingField = true

            dateSelector.date = newDate

            timePickerField.time = .time(from: newDate)

            updatingField = false
        }
    }

    override public var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }

            dateSelectField.isEnabled = isEnabled
            timePickerField.isEnabled = isEnabled
        }
    }

    override public var validationState: ValidationState {
        didSet {
            guard validationState != oldValue else { return }

            switch validationState {
            case .success:
                dateSelectField.validationState = .success()
                timePickerField.validationState = .success()

            case .error:
                dateSelectField.validationState = .error()
                timePickerField.validationState = .error()

            case .validating:
                dateSelectField.validationState = .validating
                timePickerField.validationState = .none

            case .none:
                dateSelectField.validationState = .none
                timePickerField.validationState = .none
            }
        }
    }

    private let dateSelector: DateTextSelector

    private lazy var dateSelectField = SelectInputField(selector: dateSelector, image: Icons.calendar)
        .settingContentCompressionResistanceAndHuggingPriority(.required)

    private lazy var timePickerField = TimePickerField(time: .init(hour: 11, minute: 59, period: .pm))
        .settingContentCompressionResistanceAndHuggingPriority(.required)

    private var subscription: AnyCancellable?

    private var settingDateInternally = false

    private var updatingField = false

    private let dateChanged: ((Date?) -> Void)?

    public init(minimumDate: Date? = nil, maximumDate: Date? = nil, dateChanged: ((Date?) -> Void)? = nil) {
        dateSelector = .init(minimumDate: minimumDate, maximumDate: maximumDate)

        self.dateChanged = dateChanged

        super.init(showsDefaultBackground: false, canShowDefaultValidationIndicator: false)

        initialize()
    }

    public convenience init(date: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, label: String? = nil, placeholder: String? = nil, dateChanged: ((Date?) -> Void)? = nil) {
        self.init(minimumDate: minimumDate, maximumDate: maximumDate, dateChanged: dateChanged)

        self.label = label
        self.placeholder = placeholder

        defer {
            self.date = date
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        contentInset = .nondirectionalZero

        subscription = dateSelector.$date.didChange
            .combineLatest(timePickerField.$time.didChange)
            .filter { [weak self] _, _ in
                guard let self else { return false }

                return !self.updatingField
            }
            .map { [weak self] date, time -> Date? in
                guard let self else { return nil }

                self.timePickerField.isHidden = date == nil

                if let date {
                    return time.apply(to: date)
                } else {
                    return nil
                }
            }
            .sink { [weak self] in
                self?.settingDateInternally = true
                self?.date = $0
                self?.settingDateInternally = false
            }
    }

    override public func makeContentView() -> UIView {
        VStackView(spacing: .XUI.spacing3) {
            dateSelectField

            timePickerField
                .settingHidden(true)
        }
    }
}
