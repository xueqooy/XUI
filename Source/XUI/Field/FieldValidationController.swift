//
//  FieldValidationController.swift
//  XUI
//
//  Created by xueqooy on 2023/5/8.
//

import Foundation
import UIKit

class FieldValidationController {
    public var state: Field.ValidationState = .none {
        didSet {
            if oldValue == state {
                return
            }

            var shouldShowResultLabel = false
            var shouldShowIndicatorView = false
            var resultText: String?
            var resultColor: UIColor?

            switch state {
            case let .success(text):
                resultText = text
                resultColor = Colors.green

                shouldShowResultLabel = text != nil
                shouldShowIndicatorView = false

            case let .error(text):
                resultText = text
                resultColor = Colors.red

                shouldShowResultLabel = text != nil
                shouldShowIndicatorView = false

            case .validating:
                shouldShowIndicatorView = field.canShowDefaultValidationIndicator
                shouldShowResultLabel = false

            case .none:
                shouldShowIndicatorView = false
                shouldShowResultLabel = false
            }

            // Add or remove result view
            if shouldShowResultLabel {
                if !didAddResultView {
                    field.verticalStackView.addArrangedSubview(validationResultLabel)

                    didAddResultView = true
                }

                validationResultLabel.textColor = resultColor
                validationResultLabel.text = resultText

            } else if didAddResultView {
                validationResultLabel.removeFromSuperview()

                didAddResultView = false
            }

            // Add or remove indicator view
            if shouldShowIndicatorView {
                if !didAddIndicatorView {
                    let contentIndex = field.boxStackView.arrangedSubviews.firstIndex(of: field.contentView)!

                    field.boxStackView.insertArrangedSubview(validationIndicatorView, at: contentIndex + 1)

                    didAddIndicatorView = true
                }

                validationIndicatorView.isHidden = false
                validationIndicatorView.startAnimating()

            } else if didAddIndicatorView {
                validationIndicatorView.stopAnimating()
                validationIndicatorView.removeFromSuperview()

                didAddIndicatorView = false
            }
        }
    }

    private lazy var validationIndicatorView: ActivityIndicatorView = {
        let indicator = ActivityIndicatorView()
        indicator.isHidden = true
        indicator.settingContentCompressionResistanceAndHuggingPriority(.fittingSizeLevel, for: .vertical)
        return indicator
    }()

    private lazy var validationResultLabel = UILabel(font: Fonts.body4, numberOfLines: 0)

    private var didAddIndicatorView: Bool = false
    private var didAddResultView: Bool = false

    unowned let field: Field

    init(field: Field) {
        self.field = field
    }
}
