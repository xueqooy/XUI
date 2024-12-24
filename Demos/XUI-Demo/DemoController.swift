//
//  DemoController.swift
//  XUI_Example
//
//  Created by 🌊 薛 on 2022/9/19.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Combine
import UIKit
import XKit
import XUI

class DemoController: UIViewController {
    typealias RowVerticalAlignment = FormRow.VerticalAlignment
    typealias RowAlignment = FormRow.Alignment
    typealias RowDistribution = FormRow.Distribution

    private(set) lazy var formView: FormView = {
        let formView = FormView()
        formView.itemSpacing = 20
        return formView
    }()

    var contentInset: Insets {
        set {
            formView.contentInset = newValue
        }
        get {
            formView.contentInset
        }
    }

    var cancellables = Set<AnyCancellable>()

    deinit {
        print("DemoController \(title ?? "") deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // Child scroll views interfere with largeTitleDisplayMode, so let's
        // disable it for all DemoController subclasses.
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(formView)
        formView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func createButton(image: UIImage? = nil, title: String? = nil, style: DesignedButtonConfigurationTransformer.Style = .primary, action: @escaping (Button) -> Void) -> Button {
        let button = Button(designStyle: style, touchUpInsideAction: action)
        button.configuration.title = title
        button.configuration.image = image
        return button
    }

    func createLabelAndSwitchRow(labelText: String, isOn: Bool = false, switchAction: @escaping (Bool) -> Void) -> UIView {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10

        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.body2Bold
        label.textColor = Colors.title
        label.text = labelText

        let switchView = Switch()
        switchView.isOn = isOn
        switchView.actionBlock = switchAction
        switchView.addTarget(self, action: #selector(Self.switchValueChanged(_:)), for: .valueChanged)

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(switchView)

        return stackView
    }

    func createLabelAndSwitchRow<Root: AnyObject>(labelText: String, root: Root, keyPath: WritableKeyPath<Root, Bool>) -> UIView {
        return createLabelAndSwitchRow(labelText: labelText, isOn: root[keyPath: keyPath]) { [weak root] isOn in
            guard var root = root else { return }
            root[keyPath: keyPath] = isOn
        }
    }

    func createLableAndInputFieldAndButtonRow(labelText: String, placehoder: String = "", fieldWidth _: CGFloat = 100, keyboardType: UIKeyboardType = .default, buttonTitle: String, buttonAction: @escaping (String) -> Void) -> UIStackView {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10

        let label = UILabel()
        label.font = Fonts.body2Bold
        label.textColor = Colors.title
        label.text = labelText
        stackView.addArrangedSubview(label)

        let inputField = InputField()
        inputField.placeholder = placehoder
        inputField.keyboardType = keyboardType

        let button = createButton(title: buttonTitle, style: .borderless) { [weak self] _ in
            self?.hideKeyboard()
            buttonAction(inputField.text ?? "")
        }

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(inputField)
        stackView.addArrangedSubview(button)

        inputField.widthAnchor.constraint(equalToConstant: 100).isActive = true

        return stackView
    }

    func addTitle(_ text: String) {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.h6
        titleLabel.textColor = Colors.title
        titleLabel.text = text
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        formView.addItem(FormRow(titleLabel))
    }

    func addDescription(_ text: String) {
        let descriptionLabel = UILabel()
        descriptionLabel.font = Fonts.body1
        descriptionLabel.textColor = Colors.bodyText1
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = text
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        formView.addItem(FormRow(descriptionLabel))
    }

    func addSpacer(_ spacing: CGFloat? = nil) {
        if let spacing = spacing {
            formView.addItem(FormSpacer(spacing))
        } else {
            formView.addItem(FormSpacer())
        }
    }

    func addSeparator() {
        formView.addItem(FormSeparator())
    }

    func addItem(_ item: FormItem) {
        formView.addItem(item)
    }

    @discardableResult
    func addRow(_ view: UIView, height: CGFloat? = nil, alignment: RowAlignment = .center) -> FormRow {
        let row = FormRow(view, heightMode: height != nil ? .fixed(height!) : .automatic, alignment: alignment)
        formView.addItem(row)
        return row
    }

    @discardableResult
    func addRow(_ views: [UIView], height _: CGFloat? = nil, itemSpacing: CGFloat = 0, verticalAlignment: RowVerticalAlignment = .fill, alignment: RowAlignment = .fill, distribution: RowDistribution = .fill) -> FormRow {
        let row = FormRow(views, spacing: itemSpacing, distribution: distribution, verticalAlignment: verticalAlignment, alignment: alignment)
        formView.addItem(row)
        return row
    }

    func showMessage(_ message: String, autoDismiss: Bool = true, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        (presentedViewController ?? self).present(alert, animated: true)

        if autoDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                alert.dismiss(animated: true)
            }
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                alert.dismiss(animated: true, completion: completion)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
        }
    }

    @objc private func switchValueChanged(_ sender: UISwitch) {
        sender.actionBlock?(sender.isOn)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

extension DemoController: UIPopoverPresentationControllerDelegate {
    /// Overridden to allow for popover-style modal presentation on compact (e.g. iPhone) devices.
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

private let actionBlockAssociation = Association<(Bool) -> Void>(wrap: .retain)
extension UISwitch {
    enum AssociatedKey {
        static var actionBlock = "actionBlock"
    }

    var actionBlock: ((Bool) -> Void)? {
        get {
            actionBlockAssociation[self]
        }
        set {
            actionBlockAssociation[self] = newValue
        }
    }
}
