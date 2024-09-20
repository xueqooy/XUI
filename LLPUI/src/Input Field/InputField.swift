//
//  InputField.swift
//  LLPUI
//
//  Created by xueqooy on 2023/2/23.
//

import UIKit
import SnapKit
import Combine

/// An alternative to UITextField
///
/// View Hierarchy:
/// - boxBackgroundView  (edges == boxStackView )
/// - verticalStackView
///   - labelLabel
///   - boxStackView
///     - textField
///
open class InputField: Field {

    public var text: String? {
        set {
            textInput.content = newValue
        }
        get {
            textInput.content
        }
    }
    
    public var richText: RichText? {
        set {
            textInput.richContent = newValue
        }
        get {
            textInput.richContent
        }
    }
    
    public var placeholder: String? {
        set {
            if let placeholder = newValue {
                textInput.placeholder = placeholder
            } else {
                textInput.placeholder = nil
            }
        }
        get {
            textInput.placeholder
        }
    }
    
    public override var fieldState: FieldState {
        if isEnabled {
            if contentView.isFirstResponder {
                return .active
            } else {
                return .normal
            }
        } else {
            return .disabled
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            updateTextInputEnabler()
        }
    }
    
    
    open override var isUserInteractionEnabled: Bool {
        didSet {
            updateTextInputEnabler()
        }
    }
    
    
    public var maximumTextLength: Int = .max {
        didSet {
            guard oldValue != maximumTextLength else { return }
            
            maybeUpdateTextLengthLimitPrompt()
        }
    }
    
    public var shouldDisplayTextLengthLimitPrompt: Bool = false {
        didSet {
            guard oldValue != shouldDisplayTextLengthLimitPrompt else { return }
            
            if shouldDisplayTextLengthLimitPrompt {
                if let boxStackViewIndex = verticalStackView.arrangedSubviews.firstIndex(of: boxStackView) {
                    verticalStackView.insertArrangedSubview(textLengthLimitPromptLabel, at: boxStackViewIndex + 1)
                } else {
                    verticalStackView.addArrangedSubview(textLengthLimitPromptLabel)
                }
              
                maybeUpdateTextLengthLimitPrompt()
            } else {
                textLengthLimitPromptLabel.removeFromSuperview()
            }
        }
    }

    public var allowsWhitespaceInput: Bool = true
    
    public var textPublisher: AnyPublisher<String?, Never> {
        Publishers.ControlProperty(control: self, events: .editingChanged, keyPath: \.text)
            .eraseToAnyPublisher()
    }
    
    public var editingChangedAction: ((InputField) -> Void)?
    public var editingBeganAction: ((InputField) -> Void)?
    public var editingEndedAction: ((InputField) -> Void)?
    public var editingEndedOnExitAction: ((InputField) -> Void)?
                
    private var editingEventSubscriptions = [AnyCancellable]()
    
    private lazy var textLengthLimitPromptLabel = UILabel(textColor: Colors.bodyText1, font: Fonts.caption, textAlignment: .right)
    
    lazy var textInput: TextInput = makeTextInput()
    
    
    public init() {
        super.init(showsDefaultBackground: true, canShowDefaultValidationIndicator: true)
    }

    public convenience init(label: String? = nil, placeholder: String? = nil) {
        self.init()
                
        self.label = label
        self.placeholder = placeholder
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func makeContentView() -> UIView {
        textInput.autocapitalizationType = .none
        textInput.autocorrectionType = .no
     
        updateTextInputEnabler()
        
        textInput.editingDidBeginPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            self.stateDidChange()
            self.sendActions(for: .editingDidBegin)
            self.editingBeganAction?(self)
        }.store(in: &editingEventSubscriptions)
        
        textInput.editingChangedPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            
            self.maybeUpdateTextLengthLimitPrompt()
                        
            self.sendActions(for: .editingChanged)
            self.editingChangedAction?(self)
        }.store(in: &editingEventSubscriptions)
        
        textInput.editingDidEndPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            self.stateDidChange()
            self.sendActions(for: .editingDidEnd)
            self.editingEndedAction?(self)
        }.store(in: &editingEventSubscriptions)
        
        textInput.editingDidEndOnExitPublisher?.sink { [weak self] _ in
            guard let self = self else { return }
            self.sendActions(for: .editingDidEndOnExit)
            self.editingEndedOnExitAction?(self)
        }.store(in: &editingEventSubscriptions)
        
        return textInput
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
       
        if (hitView === boxStackView || (!trailingViews.isEmpty && hitView === trailingStackView)) && canEnableTextInput {
            // If the hit view is the boxStackView, return the textInput
            return textInput
        }
        
        return hitView
    }
    
    private func maybeUpdateTextLengthLimitPrompt() {
        guard shouldDisplayTextLengthLimitPrompt else {
            return
        }
        
        guard maximumTextLength < .max else {
            textLengthLimitPromptLabel.isHidden = true
            return
        }
        
        textLengthLimitPromptLabel.isHidden = false
        
        textLengthLimitPromptLabel.text = Strings.charactersLimit(text?.count ?? 0, of: maximumTextLength)
    }
    
    private func updateTextInputEnabler() {
        if isUserInteractionEnabled && isEnabled && canEnableTextInput {
            textInput.isUserInteractionEnabled = true
        } else {
            textInput.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Provided to subclass override
    
    open override var defaultContentHeight: CGFloat {
        40
    }
    
    open func makeTextInput() -> TextInput {
        let textField = TextField()
        textField.delegate = self
        return textField
    }
    
    open var canEnableTextInput: Bool {
        true
    }
}
 

// MARK: - UITextFieldDelegate

extension InputField: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Maybe prevent from inputting whitespace
        if !allowsWhitespaceInput && string.rangeOfCharacter(from: .whitespaces) != nil {
            return false
        }
        
        // Maybe prevent text from exceeding maximum length
        if maximumTextLength < .max {            
            // If the Chinese input method is in the process of inputting Pinyin (marketTextRange is not nil), the word count should not be limited.
            if textField.markedTextRange !=  nil {
                return true
            }
            
            let textLength = (textField.text ?? "").utf16.count
            let stringLength = string.utf16.count
            let rangeLength = range.length

            if NSMaxRange(range) > textLength {
                // If the range exceeds the limit, continuing to return true will cause a crash.
                // The approach here is to return false this time and reduce the range that is out of bounds to a range that is not out of bounds, then manually replace the range
                let updatedRange = NSMakeRange(range.location, range.length - (NSMaxRange(range) - textLength))
                if updatedRange.length > 0 {
                    if let textRange = textField.convertTextRange(from: updatedRange) {
                        textField.replace(textRange, withText: string)
                    }
                }
                return false
            }
            
            if stringLength == 0 && rangeLength > 0 {
                // Allow deletion
                return true
            }
            
            if textLength - rangeLength + stringLength > maximumTextLength {
                // Text exceeds length limit, crop
                let substringLength = maximumTextLength - textLength + rangeLength
                if substringLength > 0 && stringLength > substringLength {
                    let allowedString = string.substringAvoidBreakingUpCharacterSequences(with: NSRange(location: 0, length: substringLength), lessValue: true)
                    let allowedStringLength = allowedString.utf16.count
                    if allowedStringLength <= substringLength {
                        textField.text = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: allowedString)
                        
                        // By modifying the text through setText:, the default cursor position will be at the beginning of the inserted text, which is usually not expected. Therefore, the cursor will be positioned at the end of the inserted string here
                        // Note that since the system will also modify the cursor position in the next runloop after pasting, we also need to dispatch to the next runloop to take effect, otherwise it will be overwritten by the system
                        DispatchQueue.main.async {
                            textField.selectedTextRange = textField.convertTextRange(from: NSMakeRange(range.location + allowedStringLength, 0))
                        }
                        
                        // Fire edting change event
                        sendActions(for: .editingChanged)
                    }
                }
                
                return false
            }
        }
        
        return true
    }
}


// MARK: - UIResponder

extension InputField {
    
    public override var canBecomeFirstResponder: Bool {
        isEnabled && isUserInteractionEnabled
    }
    
    public override var isFirstResponder: Bool {
        contentView.isFirstResponder
    }

    public override func becomeFirstResponder() -> Bool {
        if isEnabled && isUserInteractionEnabled {
            return contentView.becomeFirstResponder()
        } else {
            return false
        }
    }

    public override func resignFirstResponder() -> Bool {
        contentView.resignFirstResponder()
    }

}


// MARK: - UITextInputTraint

extension InputField: UITextInputTraits {
    /// default is UITextAutocapitalizationTypeSentences
    public var autocapitalizationType: UITextAutocapitalizationType {
        get {
            textInput.autocapitalizationType
        }
        set {
            textInput.autocapitalizationType = newValue
        }
    }

    /// default is UITextAutocorrectionTypeDefault
    public var autocorrectionType: UITextAutocorrectionType {
        get {
            textInput.autocorrectionType
        }
        set {
            textInput.autocorrectionType = newValue
        }
    }

    /// default is UITextSpellCheckingTypeDefault
    public var spellCheckingType: UITextSpellCheckingType {
        get {
            textInput.spellCheckingType
        }
        set {
            textInput.spellCheckingType = newValue
        }
    }

    /// default is UITextSmartQuotesTypeDefault
    public var smartQuotesType: UITextSmartQuotesType {
        get {
            textInput.smartQuotesType
        }
        set {
            textInput.smartQuotesType = newValue
        }
    }

    /// default is UITextSmartDashesTypeDefault
    public var smartDashesType: UITextSmartDashesType {
        get {
            textInput.smartDashesType
        }
        set {
            textInput.smartDashesType = newValue
        }
    }

    /// default is UITextSmartInsertDeleteTypeDefault
    public var smartInsertDeleteType: UITextSmartInsertDeleteType {
        get {
            textInput.smartInsertDeleteType
        }
        set {
            textInput.smartInsertDeleteType = newValue
        }
    }

    /// default is UIKeyboardTypeDefault
    public var keyboardType: UIKeyboardType {
        get {
            textInput.keyboardType
        }
        set {
            textInput.keyboardType = newValue
        }
    }

    /// default is UIKeyboardAppearanceDefault
    public var keyboardAppearance: UIKeyboardAppearance {
        get {
            textInput.keyboardAppearance
        }
        set {
            textInput.keyboardAppearance = newValue
        }
    }

    /// default is UIReturnKeyDefault (See note under UIReturnKeyType enum)
    public var returnKeyType: UIReturnKeyType {
        get {
            textInput.returnKeyType
        }
        set {
            textInput.returnKeyType = newValue
        }
    }

    /// default is NO (when YES, will automatically disable return key when text widget has zero-length contents, and will automatically enable when text widget has non-zero-length contents)
    public var enablesReturnKeyAutomatically: Bool {
        get {
            textInput.enablesReturnKeyAutomatically
        }
        set {
            textInput.enablesReturnKeyAutomatically = newValue
        }
    }

    /// default is NO
    public var isSecureTextEntry: Bool {
        get {
            textInput.isSecureTextEntry
        }
        set {
            textInput.isSecureTextEntry = newValue
        }
    }
    
    /// default is nil
    public var textContentType: UITextContentType! {
        get {
            textInput.textContentType
        }
        set {
            textInput.textContentType = newValue
        }
    }

    /// default is nil
    @available(iOS 12.0, *)
    public var passwordRules: UITextInputPasswordRules? {
        get {
            textInput.passwordRules
        }
        set {
            textInput.passwordRules = newValue
        }
    }
}


// MARK: - FirstResponderContainer

extension InputField: FirstResponderContainer {}
