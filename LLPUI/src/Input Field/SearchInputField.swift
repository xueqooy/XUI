//
//  SearchInputField.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/10.
//

import UIKit
import Combine

public class SearchInputField: InputField {
    
    private struct Constants {
        static let buttonWidth = 20
    }

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

    public override init() {
        super.init()

        initialize()
    }
    
    required init?(coder: NSCoder) {
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
        
        button.configuration.foregroundColor = fieldState == .disabled ? Colors.disabledText : Colors.teal
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
