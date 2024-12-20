//
//  ValueValidation+PasswordFieldValidationResult.swift
//  XUI
//
//  Created by xueqooy on 2024/6/17.
//

import Combine
import XKit

public extension ValueValidation where CustomState == (Field.ValidationState, PasswordInputField.PasswordStrengthLevel) {
    var passwordFieldValidationResultPublisher: AnyPublisher<(Field.ValidationState, PasswordInputField.PasswordStrengthLevel), Never> {
        output.validationState
            .map { state -> (Field.ValidationState, PasswordInputField.PasswordStrengthLevel) in
                switch state {
                case let .formatError(prompt):
                    return (.error(prompt), .weak)
                case let .custom(customState):
                    return customState
                default:
                    return (.none, .weak)
                }
            }
            .eraseToAnyPublisher()
    }
}
