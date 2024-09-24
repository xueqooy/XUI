//
//  SelectInputField.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/9.
//

import UIKit
import Combine
import LLPUtils

/// Non-keyboard-editable selection input field,  use `TextSelecting` to provide text input support.
public class SelectInputField: InputField {
    
    public var image: UIImage? {
        set {
            imageView.isHidden = newValue == nil
            imageView.image = newValue
        }
        get {
            imageView.image
        }
    }
    
    public override var fieldState: FieldState {
        if isEnabled {
            if isSelectActive {
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
            if oldValue == isEnabled {
                return
            }
            
            if !isEnabled && isSelectActive {
                deactivateSelector()
            }
        }
    }
     
    public override var canEnableTextInput: Bool {
        false
    }
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    public var selector: TextSelector? {
        didSet {
            guard selector !== oldValue else { return }
            
            selectorActiveSubscription = nil
            
            oldValue?.host = nil
            
            // Setup selector
            if let selector {
                selector.host = self
                selectorActiveSubscription = selector.$isActive.didChange
                    .sink { [weak self] in
                        self?.isSelectActive = $0
                    }
                
            } else {
                isSelectActive = false
            }
        }
    }
  
    private var isSelectActive: Bool = false {
        didSet {
            if oldValue == isSelectActive {
                return
            }
            
            stateDidChange()
        }
    }
    
    private lazy var layoutPropertyObserver = ViewLayoutPropertyObserver()
    
    private var layoutChangeSubscriptions = Set<AnyCancellable>()
    
    private var selectorActiveSubscription: AnyCancellable?
    
    
    public override init() {
        super.init()
        
        initialize()
    }
    
    public convenience init(selector: TextSelector? = nil, label: String? = nil, placeholder: String? = nil, image: UIImage? = nil) {
        
        self.init()
        
        self.label = label
        self.image = image
        self.placeholder = placeholder
        
        defer {
            self.selector = selector
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func stateDidChange() {
        super.stateDidChange()
        
        imageView.tintColor = fieldState == .disabled ? Colors.disabledText : Colors.teal
    }
    
    private func initialize() {
        // Setup subviews
        boxStackView.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        boxStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.boxTapped)))
        
        // Deactivate select when frame changed
        layoutPropertyObserver.propertyDidChangePublisher
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.deactivateSelector()
            }
            .store(in: &layoutChangeSubscriptions)
        layoutPropertyObserver.addToView(self)
        
        // Deactivate select when device orientation changed
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in
                Device.current.orientation
            }
            .removeDuplicates()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.deactivateSelector()
            }
            .store(in: &layoutChangeSubscriptions)
    }
    
    @objc private func boxTapped() {
        guard let selector else { return }
        
        // End other text editing
        let window = window ?? UIApplication.shared.keyWindows.first
        window?.endEditing(true)
        
        selector.activate()
    }
    
    private func deactivateSelector() {
        guard isSelectActive, let selector else { return }
        
        selector.deactivate()
    }
}


extension SelectInputField: TextSelectorHost {
    
    var selectedText: String? {
        get {
            text
        }
        set {
            text = newValue
        }
    }
    
    var selectedRichText: RichText? {
        get {
            richText
        }
        set {
            richText = newValue
        }
    }
    
    
    var selectorSourceView: UIView? {
        boxStackView
    }
}
