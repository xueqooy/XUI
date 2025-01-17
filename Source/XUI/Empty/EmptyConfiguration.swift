//
//  EmptyConfiguration.swift
//  XUI
//
//  Created by xueqooy on 2024/5/9.
//

import UIKit
import XKit

public struct EmptyConfiguration: Equatable, Then {
    public struct Action: Equatable {
        public let title: String
        public let handler: () -> Void

        private let identifier: UUID = .init()

        public init(title: String, handler: @escaping () -> Void) {
            self.title = title
            self.handler = handler
        }

        public static func == (lhs: EmptyConfiguration.Action, rhs: EmptyConfiguration.Action) -> Bool {
            lhs.identifier == rhs.identifier
        }
    }

    public enum Alignment: Equatable {
        /// The height is determined by content
        case fill(topPadding: CGFloat = .XUI.spacing10 * 3, bottomPadding: CGFloat = .XUI.spacing10 * 3)

        /// The height of the view is not determined by the content, it is always centered
        case centeredVertically(offset: CGFloat = 0)

        /// The height of the view is not determined by the conten, it is always at the top
        case top(offset: CGFloat = 0)
    }

    public var image: UIImage?

    public var text: String?

    public var detailText: String?

    public var isLoading: Bool

    public var alignment: Alignment

    public var action: Action?

    public init(image: UIImage? = nil, text: String? = nil, detailText: String? = nil, isLoading: Bool = false, alignment: Alignment = .fill(), action: Action? = nil) {
        self.image = image
        self.text = text
        self.detailText = detailText
        self.isLoading = isLoading
        self.alignment = alignment
        self.action = action
    }
}
