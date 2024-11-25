//
//  SearchInputField.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/10.
//

import UIKit
import Combine

public class SearchInputField: InputField {
    
    public typealias ActionHandler = (SearchInputField, Action) -> Void
    
    public enum Style {
        case `default`
        case large
    }
    
    public enum Action {
        case search
        case cancel
    }
    
    public let style: Style
    
    public var actionHandler: ActionHandler?

    public override var returnKeyType: UIReturnKeyType {
        set { }
        get { .search }
    }

    public override var text: String? {
        didSet {
            if oldValue == text {
                return
            }
            
            hasText = text?.isEmpty == false
        }
    }
        
    private var hasText: Bool = false {
        didSet {
            if oldValue == hasText {
                return
            }
            
            updateButtonImage()
        }
    }
    
    private lazy var button: Button = {
        let button = Button() { [weak self] _ in
            guard let self else { return }
            
            if self.hasText {
                self.cancel()
            } else {
                self.search()
            }
        }
        return button
    }()
    
    private var editingChangedSubscription: AnyCancellable?
    
    public init(style: Style = .default) {
        self.style = style
        
        super.init()

        initialize()
    }
    
    public convenience init(style: Style = .default, label: String? = nil, placeholder: String? = nil, actionHandler: ActionHandler? = nil) {
        self.init(style: style)
        
        self.label = label
        self.placeholder = placeholder
        self.actionHandler = actionHandler
    }
    
    required init?(coder: NSCoder) {
        self.style = .default
        
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {
        textInput.returnKeyType = returnKeyType
        textInput.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        
        boxStackView.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        updateButtonImage()
        
        editingChangedSubscription = textInput.editingChangedPublisher.sink { [weak self] _ in
            guard let self else { return }
            
            self.hasText = self.text?.isEmpty == false
        }
    }
    
    public override func stateDidChange() {
        super.stateDidChange()
        
        button.configuration.foregroundColor = fieldState == .disabled ? Colors.disabledText : Colors.bodyText1
    }
    
    public override var defaultContentInset: Insets {
        switch style {
        case .default:
            super.defaultContentInset
        case .large:
            .directional(top: 0, leading: .LLPUI.spacing6, bottom: 0, trailing: .LLPUI.spacing6)
        }
    }
    
    public override var defaultContentHeight: CGFloat {
        switch style {
        case .default:
            super.defaultContentHeight
        case .large:
            72
        }
    }
    
    public override func defaultBackgroundConfiguration(forFieldState fieldState: Field.FieldState, validationState: Field.ValidationState) -> BackgroundConfiguration {
        var configuration = super.defaultBackgroundConfiguration(forFieldState: fieldState, validationState: validationState)
        
        if style == .large {
            configuration.cornerStyle = .capsule
            
            if fieldState == .normal {
                configuration.strokeWidth = 0
            }
        }
                
        return configuration
    }
    
    private func search() {
        _ = resignFirstResponder()
        
        actionHandler?(self, .search)
    }
    
    private func cancel() {
        text = nil
        _ = resignFirstResponder()
        
        actionHandler?(self, .cancel)
    }

    private func updateButtonImage() {
        button.configuration.image = hasText ? Icons.xmarkSmall : Icons.search
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        
        return true
    }
}
