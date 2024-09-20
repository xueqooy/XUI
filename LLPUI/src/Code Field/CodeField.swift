//
//  CodeField.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/6.
//

import UIKit
import SnapKit
import Combine

/// Input view for code, such as SMS code, PIN code etc.
/// 
/// Support one-time input, the length of inserted text is required to be consistent with the total length.
///
/// View Hierarchy:
/// - verticalStackView
///   - labelLabel
///   - itemStackView
///     - itemView
///     - ...
///
public class CodeField: Field {
    
    private struct Constants {
        static let verticalComponentSpacing = 8.0
        static let itemSize = CGSize(width: 48, height: 48)
        static let itemSpacing: CGFloat = .LLPUI.spacing3
    }
    
    public var text: String {
        set {
            characters = newValue.prefix(length).map { $0 }
        }
        get {
            characters.reduce(into: "") { partialResult, character in
                partialResult += "\(character)"
            }
        }
    }
    
    public let length: Int
    
    public var isCompleted: Bool {
        characters.count == length
    }
    
    public var textPublisher: AnyPublisher<String, Never> {
        Publishers.ControlProperty(control: self, events: .editingChanged, keyPath: \.text)
            .eraseToAnyPublisher()
    }
    
    public var editingChangedAction: ((CodeField) -> Void)?
    public var editingBeganAction: ((CodeField) -> Void)?
    public var editingEndedAction: ((CodeField) -> Void)?
    public var inputCompletedAction: ((CodeField) -> Void)?
    
    public override var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue  else { return }
            
            updateStateOfItems()
            
            if !isEnabled && isFirstResponder {
                resignFirstResponder()
            }
        }
    }
    
    public override var validationState: Field.ValidationState {
        didSet {
            guard validationState != oldValue else { return }
            
            updateStateOfItems()
        }
    }
    
    public override var shouldShowValidationIndicator: Bool { false }
    
    private var characters = [Character]() {
        didSet {
            if oldValue == characters {
                return
            }
                        
            updateCharacterOfItems()
            updateStateOfItems()
            
            sendActions(for: .editingChanged)
            editingChangedAction?(self)
            
            if isCompleted {
                sendActions(for: .primaryActionTriggered)
                inputCompletedAction?(self)
            }
        }
    }
    
    private var focusedItemIndex: Int {
        if isCompleted {
            return length - 1
        } else {
            return characters.count
        }
    }
        
    private lazy var itemStackView: HStackView = {
        let stackView = HStackView(spacing: Constants.itemSpacing)
    
        let tapGestureRegnizer = UITapGestureRecognizer(target: self, action: #selector(Self.itemAreaTapped))
        stackView.addGestureRecognizer(tapGestureRegnizer)
        
        return stackView
    }()
    
    private lazy var itemViews: [CodeItemView] = {
        (0..<length).map { i in
            let itemView = CodeItemView()
            itemView.snp.makeConstraints { make in
                make.size.equalTo(Constants.itemSize)
            }
            return itemView
        }
    }()
    
    // MARK: - UITextInputTraits
    
    public var autocapitalizationType = UITextAutocapitalizationType.none
    public var autocorrectionType = UITextAutocorrectionType.no
    public var spellCheckingType = UITextSpellCheckingType.no
    public var keyboardType = UIKeyboardType.numberPad
    public var keyboardAppearance = UIKeyboardAppearance.default
    public var returnKeyType = UIReturnKeyType.done
    public var enablesReturnKeyAutomatically = true
    
    
    public init(label: String? = nil, length: Int = 6) {
        self.length = length
        
        super.init(showsDefaultBackground: false, canShowDefaultValidationIndicator: false)
        
        contentInset = .directionalZero
        
        self.label = label
        
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func makeContentView() -> UIView {
        HStackView {
            itemStackView
            HSpacerView.flexible()
        }
    }
    
    private func initialize() {
        itemViews.forEach { itemStackView.addArrangedSubview($0) }
        
        updateStateOfItems()
    }
    
    @objc private func itemAreaTapped() {
        if !isFirstResponder {
            becomeFirstResponder()
        }
    }
    
    private func updateStateOfItems() {
        let validationResult = switch validationState {
        
        case .success(_):
            CodeItemView.State.ValidationResult.success
        case .error(_):
            CodeItemView.State.ValidationResult.error
        default:
            CodeItemView.State.ValidationResult.none
        }
        
        if isEnabled {
            for (index, itemView) in itemViews.enumerated() {
                if index < focusedItemIndex {
                    itemView.state = .filled(validationResult)
                } else if index == focusedItemIndex {
                    if isFirstResponder {
                        itemView.state = .focused(validationResult)
                    } else {
                        itemView.state = isCompleted ? .filled(validationResult) : .normal(validationResult)
                    }
                } else {
                    itemView.state = .normal(validationResult)
                }
            }
        } else {
            itemViews.forEach { $0.state = .disabled(validationResult) }
        }
    }
    
    private func updateCharacterOfItems() {
        (0..<length).forEach { i in
            if i < characters.count {
                itemViews[i].character = characters[i]
            } else {
                itemViews[i].character = nil
            }
        }
    }
}


// MRAK: - UIResponder
extension CodeField {
    
    public override var canBecomeFirstResponder: Bool {
        isEnabled
    }
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
                
        updateStateOfItems()

        sendActions(for: .editingDidBegin)
        editingBeganAction?(self)
        
        return result
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        
        updateStateOfItems()
        
        sendActions(for: .editingDidEnd)
        editingEndedAction?(self)
                
        return result
    }
}


// MARK: - UITextInputTraits

extension CodeField: UIKeyInput {
    public var hasText: Bool {
        !characters.isEmpty
    }
    
    public func insertText(_ text: String) {
        if text.count > 1 && text.count == length {
            // Clear previous if one time input
            characters.removeAll()
        }
        
        var text = text
        while !isCompleted && !text.isEmpty {
            let character = text.removeFirst()
            self.characters.append(character)
        }
    }
    
    public func deleteBackward() {
        if characters.isEmpty {
            return
        }
        
        self.characters.removeLast()
    }
    
}
