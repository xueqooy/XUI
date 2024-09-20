//
//  FieldValidationController.swift
//  LLPUI
//
//  Created by xueqooy on 2023/5/8.
//

import Foundation

class FieldValidationController {
    
    public var state: Field.ValidationState = .none {
        didSet {
            if oldValue == state {
                return
            }
                        
            var shouldShowResultView: Bool = false
            var shouldShowIndicatorView: Bool = false
            
            switch state {
            case .success(let text):
                shouldShowResultView = text != nil
                shouldShowIndicatorView = false
                
            case .error(let text):
                shouldShowResultView = text != nil
                shouldShowIndicatorView = false
        
            case .validating:
                shouldShowIndicatorView = field.canShowDefaultValidationIndicator
                shouldShowResultView = false
        
            case .none:
                shouldShowIndicatorView = false
                shouldShowResultView = false
            }
            
            // Add or remove result view
            if shouldShowResultView {
                if !didAddResultView {
                    field.verticalStackView.addArrangedSubview(validationResultView)
                    
                    didAddResultView = true
                }
                
                validationResultView.state = state
                
            } else if didAddResultView {
                validationResultView.removeFromSuperview()
                
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
        
    private lazy var validationResultView = FieldValidationResultView()
        
    private var didAddIndicatorView: Bool = false
    private var didAddResultView: Bool = false
    
    unowned let field: Field
    
    init(field: Field) {
        self.field = field
    }
}

