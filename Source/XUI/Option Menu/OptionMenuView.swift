//
//  OptionMenuView.swift
//  XUI
//
//  Created by xueqooy on 2024/4/7.
//

import Combine
import UIKit
import XKit

public class OptionMenuView: UIView {
    public let configuration: OptionMenuConfiguration

    public var applyButtonDidTap: (() -> Void)?

    private var currentGroups: [OptionGroup]!

    private var controlMap = [String: OptionControl]()

    private lazy var cancellables = Set<AnyCancellable>()

    private lazy var titleAndClearButtonView = TitleAndButtonView(title: configuration.title, buttonConfiguration: shouldShowClearButton ? .init(title: Strings.clear) : nil) { [weak self] _ in
        guard let self else { return }

        self.resetSelectionState()
    }

    private lazy var applyButton = Button(designStyle: .primary, title: Strings.apply).then {
        $0.touchUpInsideAction = { [weak self] _ in
            guard let self else { return }

            self.applyConfiguration()

            self.applyButtonDidTap?()
        }
    }

    private var shouldShowTitle: Bool {
        !(configuration.title ?? "").isEmpty
    }

    private var shouldShowClearButton: Bool {
        configuration.action.contains(.clear)
    }

    private var shouldShowApplyButton: Bool {
        configuration.action.contains(.apply)
    }

    public init(configuration: OptionMenuConfiguration) {
        self.configuration = configuration

        super.init(frame: .zero)

        initialize()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        currentGroups = configuration.groups

        // Ignore selection state
        setupUI()

        updateSelectionState()
    }

    private func setupUI() {
        addForm(scrollingBehavior: .normal) {
            $0.contentInset = .directionalZero
            $0.itemSpacing = 0

        } populate: {
            // Title
            if shouldShowTitle || shouldShowClearButton {
                FormRow(titleAndClearButtonView)
                    .settingCustomSpacingAfter(.XUI.spacing10)
            }

            // Groups
            for (index, group) in self.currentGroups.enumerated() {
                // Group Title
                if let groupTitle = group.title {
                    FormRow(
                        UILabel(text: groupTitle, textColor: Colors.bodyText1, font: Fonts.body1Bold)
                    )
                    .settingCustomSpacingAfter(.XUI.spacing4)
                }

                // Options

                for (index, control) in createControlsForGroup(at: index).enumerated() {
                    FormRow(
                        control
                    )
                    .settingCustomSpacingAfter(index != group.options.count - 1 ? .XUI.spacing7 : 0)
                }

                // Group Bottom Spacer
                if index != self.currentGroups.count - 1 {
                    FormSpacer(.XUI.spacing10)
                }
            }

            if shouldShowApplyButton {
                FormSpacer(.XUI.spacing10)
                // Apply
                FormRow(applyButton, alignment: .center)
            }
        }
    }

    private func createControlsForGroup(at index: Int) -> [OptionControl] {
        var controls = [OptionControl]()
        var singleSelectionControlsMap = [OptionType: [OptionControl]]()

        for (optionIndex, option) in currentGroups[index].options.enumerated() {
            let control = if let richTitle = option.richTitle {
                OptionControl(style: option.type.asControlStyle, titlePlacement: .leading, richTitle: richTitle, image: option.image)
            } else {
                OptionControl(style: option.type.asControlStyle, titlePlacement: .leading, title: option.title ?? "", image: option.image)
            }
            control.isSelectedPublisher
                .dropFirst()
                .sink { [weak self] isSelected in
                    guard let self else { return }

                    self.currentGroups[index].updateSelected(isSelected, forOptionAt: optionIndex)

                    self.maybeApplyConfigurationImmediately()
                }
                .store(in: &cancellables)

            if option.type.isSingleSelection {
                var singleSelectionControls = singleSelectionControlsMap[option.type] ?? []
                singleSelectionControls.append(control)

                singleSelectionControlsMap[option.type] = singleSelectionControls
            }

            controls.append(control)

            controlMap[option.id] = control
        }

        for (_, controls) in singleSelectionControlsMap {
            if controls.count > 1 {
                let singleSelectionGroup = SingleSelectionGroup()

                for control in controls {
                    control.singleSelectionGroup = singleSelectionGroup
                }
            }
        }

        return controls
    }

    private func updateSelectionState() {
        for group in currentGroups {
            for option in group.options {
                controlMap[option.id]?.isSelected = option.isSelected
            }
        }
    }

    private func resetSelectionState() {
        var updatedGroups = currentGroups!

        for i in 0 ..< updatedGroups.count {
            updatedGroups[i].reset()
        }

        currentGroups = updatedGroups

        updateSelectionState()

        maybeApplyConfigurationImmediately()
    }

    private func applyConfiguration() {
        configuration.groups = currentGroups
    }

    private func maybeApplyConfigurationImmediately() {
        // Apply immediately if apply button does not display
        guard !shouldShowApplyButton else {
            return
        }

        applyConfiguration()
    }
}

extension OptionType {
    var asControlStyle: OptionControl.Style {
        switch self {
        case .checkbox:
            return .checkbox

        case .checkmark:
            return .checkmark

        case .radio:
            return .radio

        case .switch:
            return .switch
        }
    }
}
