//
//  DropdownMenuDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2024/5/7.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Combine
import UIKit
import XKit
import XList
import XUI

class DropdownMenuDemoController: DemoController {
    private let items = ["My Class", "What's due", "Progress", "Submission", "Start Quiz", "Create Assignment", "Create Group", "Small Group", "Calendar"]

    @EquatableState
    private var selectedItem: String = "My Class"

    private lazy var actions: [DropdownMenu.Action] = items.map {
        .init(title: $0, identifier: $0, state: $0 == selectedItem ? .on : .off) { [weak self] action in
            guard let self else { return }

            for item in self.actions {
                item.state = action === item ? .on : .off
            }

            self.selectedItem = action.title

            print("Action: \(action.title) -> State: \(action.state)")
        }
    }

    private lazy var dropdownMenu = DropdownMenu(title: "Menu Title", actions: actions)

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = XUI.Button(designStyle: .secondary, alternativeBackgroundColor: .white, contentInsetsMode: .ignoreVertical, configuration: .init(image: Icons.dropdown, imagePlacement: .trailing))

        $selectedItem.didChange
            .sink {
                button.configuration.title = $0
            }
            .store(in: &cancellables)

        view.backgroundColor = Colors.background1

        let interaction = DropdownMenuInteraction(dropdownMenu: dropdownMenu) { interaction in
            let dropdownMenu = interaction.dropdownMenu
            dropdownMenu.preference.style = .large
            dropdownMenu.preference.showsArrow = false
        }
        button.addInteraction(interaction)

        addRow(button, height: 33, alignment: .center)

        let moreButtonItem = UIBarButtonItem(image: Icons.plus, style: .plain, target: self, action: #selector(Self.buttonAction(_:)))
        navigationItem.rightBarButtonItem = moreButtonItem

        let toolItem1 = UIBarButtonItem(image: Icons.calendar, style: .plain, target: nil, action: nil)
        let toolItem2 = UIBarButtonItem(image: Icons.camera, style: .plain, target: self, action: #selector(Self.buttonAction(_:)))
        let toolItem3 = UIBarButtonItem(image: Icons.search, style: .plain, target: self, action: #selector(Self.buttonAction(_:)))
        let toolItem4 = UIBarButtonItem(image: Icons.notification, style: .plain, target: self, action: #selector(Self.buttonAction(_:)))

        toolItem1.viewPublisher.sink { [weak self] view in
            guard let view, let self else { return }

            let interaction = DropdownMenuInteraction(dropdownMenu: self.dropdownMenu) { interaction in
                let dropdownMenu = interaction.dropdownMenu
                dropdownMenu.preference.style = .plain
                dropdownMenu.preference.showsArrow = true
            }
            view.addInteraction(interaction)
        }
        .store(in: &cancellables)

        toolbarItems = [.flexibleSpace, toolItem1, .flexibleSpace, toolItem2, .flexibleSpace, toolItem3, .flexibleSpace, toolItem4, .flexibleSpace]

        // Update Actions Test
//        Queue.main.execute(.delay(3)) { [weak self] in
//            guard let self else { return }
//
//            var updatedActions = self.actions
//
//            let action = DropdownMenu.Action(title: "My Group", identifier: "My Class", attributes: .keepsMenuPresented, state: .off) { [weak self] action in
//                guard let self else { return }
//
//                self.actions.forEach {
//                    $0.state = action === $0 ? .on : .off
//                }
//
//                self.selectedItem = action.title
//
//                print("Action: \(action.title) -> State: \(action.state)")
//            }
//
//            updatedActions.removeFirst()
//            updatedActions.insert(action, at: 0)
//
//            self.actions = updatedActions
//            self.dropdownMenu.actions = updatedActions
//        }
    }

    @objc private func buttonAction(_ sender: UIBarButtonItem) {
        guard let view = sender.view else { return }

        dropdownMenu.preference.style = .plain
        dropdownMenu.preference.showsArrow = true
        dropdownMenu.show(from: view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.toolbar.tintColor = Colors.teal
        navigationController?.isToolbarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.isToolbarHidden = true
    }
}
