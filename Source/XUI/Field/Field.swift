//
//  Field.swift
//  XUI
//
//  Created by xueqooy on 2024/6/17.
//

import Combine
import SnapKit
import UIKit
import XKit

/// A content box with label, border, state and validation feature
///
/// View Hierarchy:
/// - boxBackgroundView  (edges == boxStackView ) (Optional)
/// - verticalStackView
///   - labelLabel
///   - boxStackView
///     - contentView
///
open class Field: UIControl {
    public enum Constants {
        public static let verticalComponentSpacing: CGFloat = 14
        public static let boxComponentSpacing: CGFloat = .XUI.spacing3
    }

    public enum FieldState: Equatable {
        case normal, active, disabled
    }

    public var label: String? {
        set {
            let showDisplayLabel = !(newValue ?? "").isEmpty

            if showDisplayLabel {
                if !didAddLabel {
                    verticalStackView.insertArrangedSubview(labelLabel, at: 0)

                    didAddLabel = true
                }

                labelLabel.text = newValue

            } else if didAddLabel {
                labelLabel.removeFromSuperview()

                didAddLabel = false
            }
        }
        get {
            labelLabel.text
        }
    }

    public lazy var contentInset: Insets = defaultContentInset {
        didSet {
            guard oldValue != contentInset else { return }

            boxStackView.layoutMargins = contentInset.edgeInsets(for: effectiveUserInterfaceLayoutDirection)
        }
    }

    public lazy var contentHeight: CGFloat = defaultContentHeight {
        didSet {
            guard oldValue != contentHeight else {
                return
            }

            if contentHeight == .XUI.automaticDimension {
                contentHeightConstraint.isActive = false
            } else {
                contentHeightConstraint.update(offset: contentHeight)
                contentHeightConstraint.isActive = true
            }

            // TODO: Optimize this, find a common method to invalidate the instrisincContentSize of FormSectionView
            // Invalidate the instrisincContentSize of FormView is required when the height of the height changes
            if let superFormView = findSuperview(ofType: FormView.self) {
                superFormView.invalidateIntrinsicContentSize()
            }

            contentHeightSubject.send(contentHeight)
        }
    }

    override public var isEnabled: Bool {
        didSet {
            if oldValue == isEnabled {
                return
            }

            stateDidChange()
        }
    }

    /// A Boolean value that determines whether the field responds to control events, default is false
    public var respondsToControlEvent: Bool {
        set {
            verticalStackView.isUserInteractionEnabled = !newValue
        }
        get {
            !verticalStackView.isUserInteractionEnabled
        }
    }

    public var contentHeightPublisher: AnyPublisher<CGFloat, Never> {
        contentHeightSubject.eraseToAnyPublisher()
    }

    public let boxLayoutGuide = UILayoutGuide()

    public var trailingViews: [UIView] = [] {
        didSet {
            trailingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            if !trailingViews.isEmpty {
                if trailingStackView.superview !== boxStackView {
                    boxStackView.addArrangedSubview(trailingStackView)
                }

                trailingViews.forEach { trailingStackView.addArrangedSubview($0) }

            } else {
                trailingStackView.removeFromSuperview()
            }
        }
    }

    private(set) lazy var trailingStackView = HStackView(alignment: .center, spacing: .XUI.spacing2)

    let verticalStackView = VStackView(spacing: Constants.verticalComponentSpacing)

    public private(set) lazy var boxStackView = HStackView(spacing: Constants.boxComponentSpacing)

    private(set) lazy var labelLabel: UILabel = {
        let label = UILabel()
        label.textStyleConfiguration = .label
        return label
    }()

    private lazy var boxBackgroundView = BackgroundView()

    let showsDefaultBackground: Bool

    let canShowDefaultValidationIndicator: Bool

    private(set) lazy var contentView: UIView = makeContentView()

    private var contentHeightConstraint: Constraint!

    private lazy var contentHeightSubject = CurrentValueSubject<CGFloat, Never>(defaultContentHeight)

    private var didAddLabel = false

    // MARK: - Validation

    public enum ValidationState: Equatable {
        case none
        case validating
        case success(_ text: String? = nil)
        case error(_ text: String? = nil)

        public var isError: Bool {
            if case .error = self {
                return true
            }
            return false
        }

        public var isSuccess: Bool {
            if case .success = self {
                return true
            }
            return false
        }
    }

    open var validationState: ValidationState {
        set {
            guard newValue != validationState else { return }

            validationController.state = newValue

            stateDidChange()
        }
        get {
            validationController.state
        }
    }

    private lazy var validationController = FieldValidationController(field: self)

    public init(showsDefaultBackground: Bool = true, canShowDefaultValidationIndicator: Bool = true) {
        self.showsDefaultBackground = showsDefaultBackground
        self.canShowDefaultValidationIndicator = canShowDefaultValidationIndicator

        super.init(frame: .zero)

        initialize()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().priority(.required)
        }

        boxStackView.isLayoutMarginsRelativeArrangement = true
        boxStackView.layoutMargins = contentInset.edgeInsets(for: effectiveUserInterfaceLayoutDirection)

        boxStackView.addArrangedSubview(contentView)
        contentView.snp.makeConstraints { make in
            contentHeightConstraint = make.height.equalTo(contentHeight == .XUI.automaticDimension ? 0 : contentHeight).constraint
        }

        if contentHeight == .XUI.automaticDimension {
            contentHeightConstraint.isActive = false
        }

        verticalStackView.populate {
            boxStackView
        }

        if showsDefaultBackground {
            insertSubview(boxBackgroundView, at: 0)
            boxBackgroundView.snp.makeConstraints { make in
                make.edges.equalTo(boxStackView)
            }
        }

        addLayoutGuide(boxLayoutGuide)
        boxLayoutGuide.snp.makeConstraints { make in
            make.edges.equalTo(boxStackView)
        }

        stateDidChange()
    }

    // MARK: - Provided to subclass override

    open var shouldShowValidationIndicator: Bool {
        true
    }

    open var fieldState: FieldState {
        if isEnabled {
            return .normal
        } else {
            return .disabled
        }
    }

    open var defaultContentInset: Insets {
        .directional(top: 0, leading: .XUI.spacing4, bottom: 0, trailing: .XUI.spacing4)
    }

    open var defaultContentHeight: CGFloat {
        .XUI.automaticDimension
    }

    open func makeContentView() -> UIView {
        fatalError("Subclass must override this method")
    }

    open func stateDidChange() {
        if showsDefaultBackground {
            boxBackgroundView.configuration = defaultBackgroundConfiguration(forFieldState: fieldState, validationState: validationState)
        }
    }

    open func defaultBackgroundConfiguration(forFieldState fieldState: FieldState, validationState: ValidationState) -> BackgroundConfiguration {
        var configuration = BackgroundConfiguration()
        configuration.cornerStyle = .fixed(.XUI.smallCornerRadius)
        configuration.stroke.width = 1

        switch fieldState {
        case .normal:
            configuration.stroke.color = Colors.line2
            configuration.fillColor = UIColor.white

        case .active:
            configuration.stroke.color = Colors.teal
            configuration.fillColor = UIColor.white

        case .disabled:
            configuration.stroke.color = Colors.line2
            configuration.fillColor = Colors.line1
        }

        switch validationState {
        case .success:
            if fieldState == .normal {
                configuration.fillColor = Colors.green.withAlphaComponent(0.05)
            }
            configuration.stroke.color = Colors.green
        case .error:
            if fieldState == .normal {
                configuration.fillColor = Colors.red.withAlphaComponent(0.05)
            }
            configuration.stroke.color = Colors.red
        default:
            break
        }

        return configuration
    }
}
