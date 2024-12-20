//
//  ConfirmationDialogDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/10/17.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Combine
import UIKit
import XUI

class ConfirmationDialogDemoController: DemoController {
    private lazy var timePublisher = Timer.publish(every: 1, on: .main, in: .common)
    private lazy var buttonEnabler = timePublisher
        .map { _ in Bool.random() }
        .eraseToAnyPublisher()

    private lazy var textSubject = CurrentValueSubject<String, Never>("")

    private var showsPopupTitle: Bool = false
    private var showsPopupCancelButton: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let showsPopupTitleSwitchRow = createLabelAndSwitchRow(labelText: "Show Popup Title", isOn: showsPopupTitle) { [weak self] isOn in
            self?.showsPopupTitle = isOn
        }

        let showsPopupCancelButtonSwitchRow = createLabelAndSwitchRow(labelText: "Show Popup Cancel Button", isOn: showsPopupCancelButton) { [weak self] isOn in
            self?.showsPopupCancelButton = isOn
        }

        let button = createButton(title: "Show Confirmation Dialog") { [weak self] _ in
            guard let self = self else { return }
            self.showConfirmationDialog()
        }

        addRow(showsPopupTitleSwitchRow)
        addRow(showsPopupCancelButtonSwitchRow)
        addSpacer()
        addRow(button)

        _ = timePublisher.connect()

        textSubject.sink { text in
            print(text)
        }
        .store(in: &cancellables)
    }

    private func showConfirmationDialog() {
        let buttonLabelAndRoleArray: [(String, ConfirmationDialog.ButtonRole)] = [
            ("Cancel", .cancel),
            ("Delete", .destructive),
        ]

        let nameSubject = CurrentValueSubject<String, Never>("")
        let descSubject = CurrentValueSubject<String, Never>("")

        let buttonEnabler = nameSubject
            .map {
                !$0.isEmpty
            }
            .eraseToAnyPublisher()

        nameSubject
            .merge(with: descSubject)
            .sink {
                print($0)
            }
            .store(in: &cancellables)

        ConfirmationDialog(
            popupConfiguration: .init(title: showsPopupTitle ? "Dialog Title" : nil, cancelAction: showsPopupCancelButton ? .withoutHandler : nil),
            image: Icons.trashColour,
            title: "Are you sure?",
            detailText: "Deleting an item permanently removes it and its contents."
        ) {
            for buttonLabelAndRole in buttonLabelAndRoleArray {
                CDButton(title: buttonLabelAndRole.0, role: buttonLabelAndRole.1 /* , enabler: buttonEnabler */ ) { _ in
                    print(buttonLabelAndRole.0)
                }
            }
//            CDInput(label: "Name", placeholder: "New name", textSubscriber: AnySubscriber(nameSubject))
//            CDInput(label: "Description (Optional)", placeholder: "New description", isMultiline: true, textSubscriber: AnySubscriber(descSubject))
//            CDButton(title: "Cancel", role: .cancel)
        }
        .show(in: self)
    }
}
