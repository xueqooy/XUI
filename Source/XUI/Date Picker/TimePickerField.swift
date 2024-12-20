//
//  TimePickerField.swift
//  CombineCocoa
//
//  Created by xueqooy on 2024/4/29.
//

import Combine
import UIKit
import XKit

public class TimePickerField: Field {
    public struct Time: Equatable {
        public enum Period: Equatable {
            case am, pm
        }

        // Hour is pinned to 1...12 (12-hour format)
        public var hour: Int? {
            didSet {
                guard let hour else { return }

                self.hour = max(1, min(12, hour))
            }
        }

        // Minute is pinned to 0...59
        public var minute: Int? {
            didSet {
                guard let minute else { return }

                self.minute = max(0, min(59, minute))
            }
        }

        public var period: Period = .am

        public init(hour: Int? = nil, minute: Int? = nil, period: Period = .am) {
            self.period = period

            defer {
                self.hour = hour
                self.minute = minute
            }
        }
    }

    @EquatableState
    public var time: Time = .init() {
        didSet {
            guard oldValue != time else { return }

            update()
        }
    }

    override public var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }

            hourField.isEnabled = isEnabled
            minuteField.isEnabled = isEnabled

            periodControl.isEnabled = isEnabled
        }
    }

    override public var validationState: ValidationState {
        didSet {
            guard validationState != oldValue else { return }

            switch validationState {
            case .success:
                hourField.validationState = .success()
                minuteField.validationState = .success()

                periodControl.backgroundView.configuration.stroke.color = Colors.green

            case .error:
                hourField.validationState = .error()
                minuteField.validationState = .error()

                periodControl.backgroundView.configuration.stroke.color = Colors.red

            default:
                hourField.validationState = .none
                minuteField.validationState = .none

                periodControl.backgroundView.configuration.stroke.color = Colors.line2
            }
        }
    }

    override public var defaultContentHeight: CGFloat { 40 }

    override public var shouldShowValidationIndicator: Bool { false }

    private lazy var hourField = createField(withNumberRange: 1 ... 12)

    private lazy var minuteField = createField(withNumberRange: 0 ... 59)

    private let periodControl = SegmentControl(style: .toggle, fillEqually: false, items: ["AM", "PM"]).then {
        $0.selectedSegmentIndex = 0
    }

    private var cancellables = Set<AnyCancellable>()

    public init(label: String? = nil, time: Time = .init()) {
        super.init(showsDefaultBackground: false, canShowDefaultValidationIndicator: false)

        contentInset = .directionalZero

        self.label = label
        self.time = time

        update()

        performBinding()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func makeContentView() -> UIView {
        let colonLabel = UILabel(text: ":", textColor: Colors.title, font: Fonts.body1Bold)
            .settingContentCompressionResistanceAndHuggingPriority(.required)

        return HStackView {
            hourField
                .settingCustomSpacingAfter(6)
            colonLabel
                .settingCustomSpacingAfter(6)
            minuteField

            HSpacerView(.XUI.spacing3, compressionResistancePriority: .required)

            periodControl

            HSpacerView.flexible()
        }
    }

    private func createField(withNumberRange numberRange: ClosedRange<Int>) -> SelectInputField {
        let selector = WheelTextSelector(items: numberRange.map {
            String(format: "%02d", $0)
        })

        let field = SelectInputField(selector: selector, placeholder: "00")
        field.textStyleConfiguration.textAlignment = .center
        field.settingWidthConstraint(67)

        return field
    }

    private func performBinding() {
        hourField.textPublisher
            .sink { [weak self] text in
                guard let self else { return }

                self.time.hour = if let text {
                    Int(text)
                } else {
                    nil
                }
            }
            .store(in: &cancellables)

        minuteField.textPublisher
            .sink { [weak self] text in
                guard let self else { return }

                self.time.minute = if let text {
                    Int(text)
                } else {
                    nil
                }
            }
            .store(in: &cancellables)

        periodControl.selectedSegmentIndexPublisher
            .sink { [weak self] index in
                guard let self = self else { return }

                self.time.period = (index == 0) ? .am : .pm
            }
            .store(in: &cancellables)
    }

    private func update() {
        if let hour = time.hour {
            hourField.text = String(format: "%02d", hour)
        } else {
            hourField.text = nil
        }

        if let minute = time.minute {
            minuteField.text = String(format: "%02d", minute)
        } else {
            minuteField.text = nil
        }

        periodControl.selectedSegmentIndex = (time.period == .pm) ? 1 : 0
    }
}

public extension TimePickerField.Time {
    var hour24: Int? {
        return if let hour12 = hour {
            // convert 12-hour to 24-hour
            if period == .pm {
                (hour12 == 12) ? 12 : hour12 + 12
            } else {
                (hour12 == 12) ? 0 : hour12
            }
        } else {
            nil
        }
    }

    var isComplete: Bool {
        hour != nil && minute != nil
    }

    static func time(from date: Date?) -> Self {
        guard let date else {
            return .init()
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)

        guard let hour24 = components.hour, let minute = components.minute else {
            return .init()
        }

        // Determine AM/PM
        let period: Period = hour24 >= 0 && hour24 < 12 ? .am : .pm

        // Convert hour to 12-hour format
        var hour12 = hour24 % 12
        if hour12 == 0 {
            hour12 = 12
        }

        return .init(hour: hour12, minute: minute, period: period)
    }

    func apply(to date: Date) -> Date? {
        guard let hour24, let minute else { return nil }

        let calendar = Calendar.current
        let originDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        let second = originDateComponents.second!

        return calendar.date(bySettingHour: hour24, minute: minute, second: second, of: date) ?? date
    }
}

extension TimePickerField.Time: CustomStringConvertible {
    public var description: String {
        // h:mm a
        "\(hour != nil ? "\(hour!)" : "-"):\(minute != nil ? "\(minute!)" : "-") \(period == .am ? "am" : "pm")"
    }
}
