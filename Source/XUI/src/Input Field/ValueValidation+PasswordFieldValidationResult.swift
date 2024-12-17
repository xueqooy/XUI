//
//  ValueValidation+PasswordFieldValidationResult.swift
//  XUI
//
//  Created by xueqooy on 2024/6/17.
//

import XKit
import Combine

public extension ValueValidation where CustomState == (Field.ValidationState, PasswordInputField.PasswordStrengthLevel) {
    
    var passwordFieldValidationResultPublisher: AnyPublisher<(Field.ValidationState, PasswordInputField.PasswordStrengthLevel), Never> {
        output.validationState
            .map { state -> (Field.ValidationState, PasswordInputField.PasswordStrengthLevel) in
                switch state {
                case .formatError(let prompt):
                    return (.error(prompt), .weak)
                case .custom(let customState):
                    return customState
                default:
                    return (.none, .weak)
                }
            }
            .eraseToAnyPublisher()
    }
}
