//
//  SearchInputField.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/10.
//

import UIKit
import Combine

public class SearchInputField: InputField {
    
    public enum Style {
        case `default`
        case large
    }
    
    private struct Constants {
        static let buttonWidth = 20
    }
    
    public let style: Style

    public override var returnKeyType: UIReturnKeyType {
        set { }
        get { .search }
    }
    
    public override var enablesReturnKeyAutomatically: Bool {
        set { }
        get { true }
    }
    
    private var isActive: Bool = false {
        didSet {
            if oldValue == isActive {
                return
            }
            
            updateButtonImage()
        }
    }
    
    public override var text: String? {
        didSet {
            if oldValue == text {
                return
            }
            
            updateActiveState()
        }
    }
    
    private lazy var button: Button = {
        let button = Button() { [weak self] _ in
            guard let self = self, self.isActive else { return }
            
            self.deactivate()
        }
        return button
    }()
    
    private var editingChangedSubscription: AnyCancellable?
    

    public init(style: Style = .default) {
        self.style = style
        
        super.init()

        initialize()
    }
    
    public convenience init(style: Style = .default, label: String? = nil, placeholder: String? = nil) {
        self.init(style: style)
        
        self.label = label
        self.placeholder = placeholder
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
            make.width.equalTo(Constants.buttonWidth)
        }
        
        updateButtonImage()
        
        editingChangedSubscription = textInput.editingChangedPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            
            self.updateActiveState()
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
    
    
    private func deactivate() {
        text = nil
        _ = resignFirstResponder()
    }
    
    private func updateActiveState() {
        isActive = text?.isEmpty == false
    }
    
    private func updateButtonImage() {
        button.configuration.image = isActive ? Icons.xmarkSmall : Icons.search
    }
}
