//
//  ConfirmationDialog.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/17.
//

import UIKit
import LLPUtils
import Combine

public protocol ConfirmationDialogToken {
    func updateLayout(animted: Bool)
    
    func hide()
}

private struct PopupControllerWrapper: ConfirmationDialogToken {
    
    private weak var popupController: PopupController?
    
    init(_ popupController: PopupController?) {
        self.popupController = popupController
    }
    
    func updateLayout(animted: Bool) {
        popupController?.contentView?.invalidateIntrinsicContentSize()
        popupController?.updateLayout(animated: animted)
    }
    
    func hide() {
        popupController?.presentingViewController?.dismiss(animated: true)
    }
}


public class ConfirmationDialog {
    
    public typealias CustomViewAlignment = FormRow.Alignment
    
    public enum ButtonRole: Int, Comparable {
        public static func < (lhs: ConfirmationDialog.ButtonRole, rhs: ConfirmationDialog.ButtonRole) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
        
        case primary = 1, destructive, cancel
    }
        
    public enum Element {
    
        case input(label: String? = nil, placeholder: String? = nil, isMultiline: Bool = false, maximumTextLength: Int = .max, textSubscriber: any Subscriber<String, Never>)
                
        case button(title: String, role: ButtonRole = .primary, enabler: (any Publisher<Bool, Never>)? = nil, keepsDialogPresented: Bool = false, handler: ((ConfirmationDialogToken) -> Void)? = nil)
        
        case customView(UIView, height: CGFloat? = nil, alignment: CustomViewAlignment = .fill, insets: UIEdgeInsets? = nil)
        
        var order: Int {
            switch self {
            case .input(_, _, _, _, _):
                0
            case .button(_, let role, _, _, _):
                role.rawValue
            case .customView(_, _, _, _):
                0
            }
        }
        
        var isButton: Bool {
            switch self {
            case .button:
                return true
            default:
                return false
            }
        }
    }
    
    public static let defaultPopupConfiguration = PopupController.Configuration(showsCancelButton: true)
    
    private static let cancellablesAssociation = Association<Set<AnyCancellable>>(wrap: .retain)
    
    private let popupConfiguration: PopupController.Configuration
    private let title: String?
    private let image: UIImage?
    private let imageSize: CGSize?
    private let detailText: String?
    private let detailRichText: RichText?
    private let elements: [Element]
    
    private let buttonElements: [Element]
    private var shouldAddButtonsHorizontally: Bool = false
    
    public init(popupConfiguration: PopupController.Configuration = ConfirmationDialog.defaultPopupConfiguration, image: UIImage? = nil, imageSize: CGSize? = nil, title: String? = nil, detailText: String? = nil, detailRichText: RichText? = nil, elements: [Element] = []) {
        self.popupConfiguration = popupConfiguration
        self.image = image
        self.imageSize = imageSize
        self.title = title
        self.detailText = detailText
        self.detailRichText = detailRichText
        // Sort actions by comparing button role
        self.elements = elements.sorted(by: { $0.order < $1.order } )
        
        buttonElements = elements.filter { $0.isButton }
 
        shouldAddButtonsHorizontally = buttonElements.count == 2
    }
    
    @discardableResult
    public func show(in viewController: UIViewController) -> ConfirmationDialogToken {
        let popupController = PopupController(configuration: popupConfiguration)
        popupController.contentView = createContentView(for: popupController)
                
        viewController.present(popupController, animated: true)
        
        return PopupControllerWrapper(popupController)
    }
    
    private func createContentView(for popupController: PopupController) -> UIView {
        var cancellables = Set<AnyCancellable>()
        
        let formView = FormView()
        formView.contentInset = .nondirectional(top: (popupConfiguration.title ?? "").isEmpty && !popupConfiguration.showsCancelButton ? .LLPUI.spacing5 : 0, left: 0, bottom: .LLPUI.spacing5, right: 0)
        formView.itemSpacing = 0
                
        formView.populate {
            if let image = image {
                if let imageSize {
                    FormRow(
                        UIImageView(
                            image: image,
                            contentMode: .scaleAspectFit
                        ).settingSizeConstraint(imageSize),
                        alignment: .center
                    )
                    .settingCustomSpacingAfter(.LLPUI.spacing5)
                } else {
                    FormRow(
                        UIImageView(
                            image: image,
                            contentMode: .scaleAspectFit
                        ),
                        alignment: .center
                    )
                    .settingCustomSpacingAfter(.LLPUI.spacing5)
                }
            }
            
            if let title, !title.isEmpty {
                FormRow(
                    UILabel(
                        text: title,
                        textColor: Colors.bodyText1,
                        font: Fonts.body2Bold,
                        textAlignment: .center,
                        numberOfLines: 0
                    ),
                    alignment: .center
                )
                .settingCustomSpacingAfter(!(detailText ?? "").isEmpty ? .LLPUI.spacing3 : .LLPUI.spacing5)
            }
            
            if let detailRichText, !detailRichText.attributedString.string.isEmpty {
                FormRow(
                    UILabel(
                        richText: detailRichText,
                        textColor: Colors.bodyText1,
                        font: Fonts.body2,
                        textAlignment: .center,
                        numberOfLines: 0
                    ).then { $0.isUserInteractionEnabled = true }, // rich text may contain action, so enable user interaction
                    alignment: .center
                )
                .settingCustomSpacingAfter(.LLPUI.spacing5)
                
            } else if let detailText, !detailText.isEmpty {
                FormRow(
                    UILabel(
                        text: detailText,
                        textColor: Colors.bodyText1,
                        font: Fonts.body2,
                        textAlignment: .center,
                        numberOfLines: 0
                    ),
                    alignment: .center
                )
                .settingCustomSpacingAfter(.LLPUI.spacing5)
            }
            
            for element in elements {
                switch element {
                case .input(let label, let placeholder, let isMultiline, let maximumTextLength, let textSubscriber):
                    FormRow(
                        {
                            let inputField: InputField
    
                            if isMultiline {
                                inputField = MultilineInputField(label: label, placeholder: placeholder)
                                (inputField as! MultilineInputField).allowedAdditionalHeight = 0
                            } else {
                                inputField = InputField(label: label, placeholder: placeholder)
                            }
                            
                            inputField.maximumTextLength = maximumTextLength
                            inputField.textPublisher
                                .map { $0 ?? "" }
                                .receive(subscriber: textSubscriber)
                            
                            return inputField
                        }(),
                        alignment: .fill
                    )
                    .settingCustomSpacingAfter(.LLPUI.spacing5)
                    
                case .button where !shouldAddButtonsHorizontally:
                    FormRow(
                        WrapperView(
                            createButton(for: element, popupController: popupController, cancellables: &cancellables),
                            layoutMargins: .init(top: 0, left: .LLPUI.spacing5, bottom: 0, right: .LLPUI.spacing5)
                        ),
                        height: 48,
                        alignment: .fill
                    )
                    .settingCustomSpacingAfter(.LLPUI.spacing3)
                
                case .customView(let view, let height, let alignment, let insets):
                    FormRow(view, height: height, alignment: alignment, insets: insets)
                        .settingCustomSpacingAfter(.LLPUI.spacing5)
                    
                default:
                    ()
                }
            }
        }
        
        if shouldAddButtonsHorizontally {
            addButtonsVertically(for: formView, popupController: popupController, cancellables: &cancellables)
        }
        
        if !cancellables.isEmpty {
            Self.cancellablesAssociation[formView] = cancellables
        }
        
        return formView
    }
    
    private func addButtonsVertically(for formView: FormView, popupController: PopupController, cancellables: inout Set<AnyCancellable>) {
        formView.populate(keepPreviousItems: true) {
            FormRow(spacing: .LLPUI.spacing4, height: 48, distribution: .fillEqually) {
                for buttonElement in buttonElements {
                    createButton(for: buttonElement, popupController: popupController, cancellables: &cancellables)
                }
            }
        }
    }
    
    private func createButton(for element: Element, popupController: PopupController, cancellables: inout Set<AnyCancellable>) -> Button {
        guard case let .button(title, role, enabler, keepsDialogPresented, handler) = element else {
            fatalError()
        }

        let button = Button(
            designStyle: role == .primary || role == .destructive ? .primary : .secondary,
            mainColor: role == .destructive ? Colors.red : Colors.teal,
            contentInsetsMode: .ignoreHorizontal,
            title: title,
            touchUpInsideAction: { [weak popupController] _ in
                
                if !keepsDialogPresented, let presentingViewController = popupController?.presentingViewController {
                    
                    presentingViewController.dismiss(animated: true) {
                        handler?(PopupControllerWrapper(popupController))
                    }
                    
                } else {
                    handler?(PopupControllerWrapper(popupController))
                }
            })
        
        enabler?
            .assign(to: \.isEnabled, on: button)
            .store(in: &cancellables)
        
        return button
    }
}

