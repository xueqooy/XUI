//
//  MobileNumberInputField.swift
//  LLPUI
//
//  Created by xueqooy on 2023/2/23.
//

import UIKit
import SnapKit
import Combine

/// A mobile number input field  with area code selection button
public class MobileNumberInputField: InputField {

    private struct Constants {
        static let codeImagePadding = 12.0
    }
    
    public var codeText: String? {
        set {
            codeButton.configuration.title = newValue
        }
        get {
            codeButton.configuration.title
        }
    }
    
    public var codeSelector: TextSelector? {
        didSet {
            guard codeSelector !== oldValue else { return }
            
            codeSelectorActiveSubscription = nil
            
            oldValue?.host = nil
            
            // Setup selector
            if let codeSelector {
                codeSelector.host = self
                codeSelectorActiveSubscription = codeSelector.$isActive.didChange
                    .sink { [weak self] in
                        self?.codeBackgroundView.configuration.strokeWidth = $0 ? 1 : 0
                    }
            } else {
                codeBackgroundView.configuration.strokeWidth = 0
            }
        }
    }
    
    private lazy var codeButton: Button = {
        var configuration = ButtonConfiguration()
        configuration.titleFont = Fonts.body2
        configuration.titleColor = Colors.title
        configuration.image = Icons.dropdown
        configuration.imagePlacement = .right
        configuration.imagePadding = Constants.codeImagePadding
       
        let button = Button(configuration: configuration) { [weak self] _ in
            guard let self, let codeSelector = self.codeSelector else {
                return
            }
            
            codeSelector.activate()
        }
        return button
    }()
    
    private lazy var codeBackgroundView: BackgroundView = {
        let isLTR = UIView.userInterfaceLayoutDirection(for: UIView.appearance().semanticContentAttribute) == .leftToRight
        let configuration = BackgroundConfiguration(strokeColor: Colors.vibrantTeal, cornerStyle: .fixed(.LLPUI.smallCornerRadius), stylishCorners: isLTR ? [.topLeft, .bottomLeft] : [.topRight, .bottomRight])
               
        return BackgroundView(configuration: configuration)
    }()
    
    private let seperator = SeparatorView(orientation: .vertical)
        
    private var editingBeganSubscription: AnyCancellable?
    
    private var codeSelectorActiveSubscription: AnyCancellable?
    
    public override init() {
        super.init()

        initialize()
    }
    
    public convenience init(codeSelector: TextSelector, label: String? = nil, placeholder: String? = nil) {
        self.init()
        
        self.label = label
        self.placeholder = placeholder
        
        defer {
            self.codeSelector = codeSelector
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        textInput.keyboardType = .numberPad
        
        boxStackView.insertArrangedSubview(codeButton, at: 0)
        boxStackView.insertArrangedSubview(seperator, at: 1)
        
        boxStackView.addSubview(codeBackgroundView)
        codeBackgroundView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(seperator.snp.trailing)
        }

        
        // Select code first before input phone number.
        editingBeganSubscription = controlEventPublisher(for: .editingDidBegin)
            .filter { [weak self] _ in
                self?.codeText == nil
            }
            .sink(receiveValue: { [weak self] _ in
                guard let self, let codeSelector = self.codeSelector else { return }
                
                _ = self.resignFirstResponder()
                
                codeSelector.activate()
            })
    }
    
    public override func stateDidChange() {
        super.stateDidChange()
        
        seperator.color = defaultBackgroundConfiguration(forFieldState: fieldState, validationState: validationState).strokeColor
        codeButton.configuration.foregroundColor = fieldState == .disabled ? Colors.disableText : Colors.vibrantTeal

    }
}


extension MobileNumberInputField: TextSelectorHost {
    
    var selectedText: String? {
        get {
            codeText
        }
        set {
            codeText = newValue
        }
    }
    
    var selectedRichText: RichText? {
        get {
            nil
        }
        set {
        }
    }
    
    
    var selector: TextSelector? {
        get {
            codeSelector
        }
        set {
            codeSelector = newValue
        }
    }
    
    
    var selectorSourceView: UIView? {
        codeButton
    }
}