//
//  ConfirmationDialog.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/17.
//

import UIKit
import LLPUtils
import Combine

public class ConfirmationDialog {
    
    public typealias CustomViewAlignment = FormRow.Alignment
    
    public enum ButtonRole: Int, Comparable {
        public static func < (lhs: ConfirmationDialog.ButtonRole, rhs: ConfirmationDialog.ButtonRole) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
        
        case primary = 1, secondary, cancel
    }
        
    public enum Element {
    
        case input(label: String? = nil, placeholder: String? = nil, isMultiline: Bool = false, maximumTextLength: Int = .max, textSubscriber: any Subscriber<String, Never>)
                
        case button(title: String, role: ButtonRole = .primary, enabler: AnyPublisher<Bool, Never>? = nil, handler: (() -> Void)? = nil)
        
        case customView(UIView, height: CGFloat? = nil, alignment: CustomViewAlignment = .fill, insets: UIEdgeInsets? = nil)
        
        var order: Int {
            switch self {
            case .input(_, _, _, _, _):
                0
            case .button(_, let role, _, _):
                role.rawValue
            case .customView(_, _, _, _):
                0
            }
        }
    }
    
    public static let defaultPopupConfiguration = PopupController.Configuration(showsCancelButton: false)
    
    private static let cancellablesAssociation = Association<Set<AnyCancellable>>(wrap: .retain)
    
    private let popupConfiguration: PopupController.Configuration
    private let title: String?
    private let image: UIImage?
    private let imageSize: CGSize?
    private let detailText: String?
    private let detailRichText: RichText?
    private let elements: [Element]
    
    public init(popupConfiguration: PopupController.Configuration = ConfirmationDialog.defaultPopupConfiguration, image: UIImage? = nil, imageSize: CGSize? = nil, title: String? = nil, detailText: String? = nil, detailRichText: RichText? = nil, elements: [Element] = []) {
        self.popupConfiguration = popupConfiguration
        self.image = image
        self.imageSize = imageSize
        self.title = title
        self.detailText = detailText
        self.detailRichText = detailRichText
        // Sort actions by comparing button role
        self.elements = elements.sorted(by: { $0.order < $1.order } )
    }
    
    public func show(in viewController: UIViewController) {
        let popupController = PopupController(configuration: popupConfiguration)
        popupController.contentView = createContentView(for: popupController)
                
        viewController.present(popupController, animated: true)
    }
    
    private func createContentView(for presentedController: UIViewController) -> UIView {
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
                        textColor: Colors.title,
                        font: Fonts.body1Bold,
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
                    
                case .button(let title, let role, let enabler, let handler):
                    FormRow(
                        WrapperView({
                            let button = Button(
                                designStyle: role == .primary ? .primary : .secondary,
                                contentInsetsMode: .ignoreHorizontal,
                                title: title,
                                touchUpInsideAction: { [weak presentedController] _ in
                                    if let presentedController = presentedController {
                                        presentedController.dismiss(animated: true, completion: handler)
                                    } else {
                                        handler?()
                                    }
                                })
                            
                            enabler?
                                .assign(to: \.isEnabled, on: button)
                                .store(in: &cancellables)
                            
                            return button
                        }(), layoutMargins: .init(top: 0, left: .LLPUI.spacing5, bottom: 0, right: .LLPUI.spacing5)
                        ),
                        height: 40,
                        alignment: .fill
                    )
                    .settingCustomSpacingAfter(.LLPUI.spacing3)
                
                case .customView(let view, let height, let alignment, let insets):
                    FormRow(view, height: height, alignment: alignment, insets: insets)
                        .settingCustomSpacingAfter(.LLPUI.spacing5)
                }
            }
        }
        
        if !cancellables.isEmpty {
            Self.cancellablesAssociation[formView] = cancellables
        }
        
        return formView
    }
}

