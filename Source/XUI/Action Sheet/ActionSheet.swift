//
//  ActionSheet.swift
//  XUI
//
//  Created by xueqooy on 2023/10/11.
//

import UIKit

public class ActionSheet {
    public typealias CustomViewAlignment = FormRow.Alignment

    public enum Element {
        case button(title: String? = nil, richTitle: RichText? = nil, image: UIImage? = nil, keepsSheetPresented: Bool = false, handler: (() -> Void)? = nil)

        case label(String? = nil, RichText? = nil)

        case separator

        case customView(UIView, height: CGFloat? = nil, alignment: CustomViewAlignment = .fill, insets: UIEdgeInsets? = nil)
    }

    private let title: String?
    private let elements: [Element]

    private lazy var buttonTransformer = ActionSheetButtonConfigurationTransformer()

    public init(title: String? = nil, elements: [Element]) {
        self.title = title
        self.elements = elements
    }

    @MainActor public func show(in viewController: UIViewController, sourceView: UIView? = nil, sourceRect: CGRect? = nil) {
        let presentationStyle: DrawerController.PresentationStyle = sourceView == nil && sourceRect == nil ? .slideover : .automatic
        let sourceRect = sourceRect ?? sourceView?.bounds ?? CGRect(origin: viewController.view.center, size: .zero)
        let sourceView = sourceView ?? viewController.view!
        let configuration: DrawerController.Configuration = .init(presentationStyle: presentationStyle, presentationDirection: .up, resizingBehavior: .dismiss)

        let drawer = DrawerController(sourceView: sourceView, sourceRect: sourceRect, configuration: configuration)
        drawer.contentView = createContentView(for: drawer)
        // For popover in pad and landscape in phone
        drawer.preferredContentSize = .init(width: viewController.view.bounds.width / 2, height: 0)

        viewController.present(drawer, animated: true)
    }

    private func createContentView(for presentedController: UIViewController) -> UIView {
        let formView = FormView()
        formView.contentInset = .directionalZero
        formView.itemSpacing = .XUI.spacing1

        formView.populate {
            if let title = title {
                FormRow(
                    UILabel(text: title, textColor: Colors.title, font: Fonts.body1Bold),
                    alignment: .center
                )
                .settingCustomSpacingAfter(.XUI.spacing6)
            }

            for element in elements {
                switch element {
                case let .button(title, richTitle, image, keepsSheetPresented, handler):
                    FormRow(
                        Button(
                            configuration: .init(
                                image: image,
                                title: title,
                                richTitle: richTitle
                            ),
                            configurationTransformer: buttonTransformer,
                            touchUpInsideAction: { [weak presentedController] _ in
                                if !keepsSheetPresented, let presentedController {
                                    presentedController.dismiss(animated: true, completion: handler)

                                } else {
                                    handler?()
                                }
                            }
                        ).then { $0.contentHorizontalAlignment = .leading },
                        heightMode: .fixed(44),
                        alignment: .fill
                    )

                case let .label(text, richText):
                    FormRow(
                        UILabel(
                            text: text,
                            richText: richText,
                            textColor: Colors.bodyText1,
                            font: Fonts.body1Bold
                        )
                    )

                case .separator:
                    FormSpacer(.XUI.spacing4)
                    FormSeparator()
                        .settingCustomSpacingAfter(.XUI.spacing7)

                case let .customView(view, height, alignment, insets):
                    FormRow(view, heightMode: height != nil ? .fixed(height!) : .automatic, alignment: alignment, insets: insets)
                }
            }
        }
        return formView
    }
}
