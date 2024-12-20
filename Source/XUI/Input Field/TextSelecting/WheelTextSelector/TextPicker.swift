//
//  TextPicker.swift
//  XUI
//
//  Created by xueqooy on 2024/4/29.
//

import UIKit
import XKit

class TextPicker: UIPickerView {
    var items: [String] = [] {
        didSet {
            guard oldValue != items else { return }

            reloadAllComponents()
        }
    }

    var selectedItem: String? {
        let selectedIndex = selectedRow(inComponent: 0)

        guard selectedIndex != -1 else { return nil }

        return items[selectedIndex]
    }

    private let selectHandler: (String) -> Void

    init(items: [String], selectHandler: @escaping (String) -> Void) {
        self.selectHandler = selectHandler

        super.init(frame: .zero)

        delegate = self
        dataSource = self

        defer {
            self.items = items
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateSelection() {}
}

extension TextPicker: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in _: UIPickerView) -> Int {
        1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        items.count
    }

    func pickerView(_: UIPickerView, viewForRow row: Int, forComponent _: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel(textStyleConfiguration: .init(textColor: .black, font: Fonts.body1, textAlignment: .center))

        label.text = items[row]

        return label
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        selectHandler(items[row])
    }
}
