//
//  ValueValidation+FieldValidationState.swift
//  XUI
//
//  Created by xueqooy on 2023/9/12.
//

import Combine
import XKit

public extension ValueValidation where CustomState == Field.ValidationState {
    var fieldValidationStatePublisher: AnyPublisher<Field.ValidationState, Never> {
        output.validationState
            .map { state -> Field.ValidationState in
                Self.fieldValidationState(for: state)
            }
            .eraseToAnyPublisher()
    }

    var fieldValidationState: Field.ValidationState {
        Self.fieldValidationState(for: state)
    }

    private static func fieldValidationState(for state: ValueValidation.State) -> Field.ValidationState {
        switch state {
        case .none:
            return .none
        case let .formatError(prompt):
            return .error(prompt)
        case .unknownError:
            // We should handle this type of error separately
            return .none
        case let .custom(customState):
            return customState
        }
    }
}
