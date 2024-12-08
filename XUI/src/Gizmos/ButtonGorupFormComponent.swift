//
//  ButtonGorupFormComponent.swift
//  XUI
//
//  Created by xueqooy on 2023/5/8.
//

import UIKit
import Combine

public class ButtonGroupFormComponent {
    private lazy var formView: FormView = {
        let formView = FormView(contentScrollingBehavior: .limited)
        formView.itemSpacing = buttonSpacing
        formView.contentInset = contentInset
        formView.scrollingContainer.clipsToBounds = false
        return formView
    }()
    
    private let buttonDidTapSubject = PassthroughSubject<Int, Never>()
    public var buttonDidTapPublisher: AnyPublisher<Int, Never> {
        buttonDidTapSubject.eraseToAnyPublisher()
    }
    
    public private(set) var buttons = [Button]()
    
    public var configurations: [ButtonConfiguration] {
        didSet {
            if oldValue != configurations {
                updateForm()
            }
        }
    }
    
    public var configurationTransformer: ButtonConfigurationTransforming? {
        didSet {
            buttons.forEach { $0.configurationTransformer = configurationTransformer }
        }
    }
    
    public var buttonSpacing: CGFloat {
        didSet {
            guard buttonSpacing != oldValue else {
                return
            }
            
            formView.itemSpacing = buttonSpacing
        }
    }
    
    public var contentInset: Insets {
        didSet {
            guard contentInset != oldValue else {
                return
            }
            
            formView.contentInset = contentInset
        }
    }
    
    public var width: CGFloat? = nil {
        didSet {
            if let width = width {
                formView.widthAnchor.constraint(equalToConstant: width).isActive = true
            } else {
                formView.widthAnchor.constraint(equalToConstant: 0).isActive = false
            }
        }
    }
    
    public init(configurations: [ButtonConfiguration] = [], configurationTransformer: ButtonConfigurationTransforming? = nil, buttonSapcing: CGFloat = .XUI.spacing6, contentInset: Insets = .nondirectionalZero, width: CGFloat? = nil) {
        self.configurations = configurations
        self.configurationTransformer = configurationTransformer
        self.contentInset = contentInset
        self.buttonSpacing = buttonSapcing
        self.width = width
        
        updateForm()
    }

    private func updateForm() {
        buttons = (0..<configurations.count).map { createButton(for: $0) }
        formView.populate {
            for button in buttons {
                FormRow(button)
            }
        }
    }
    
    private func createButton(for index: Int) -> Button {
       Button(configuration: configurations[index], configurationTransformer: configurationTransformer) { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.buttonDidTapSubject.send(index)
        }
    }
}

extension ButtonGroupFormComponent: FormComponent {
    public func asFormItems() -> [FormItem] {
        [
            FormRow(formView, alignment: width == nil ? .fill : .center)
        ]
    }
}

