//
//  EmptyConfiguration.swift
//  LLPUI
//
//  Created by xueqooy on 2024/5/9.
//

import UIKit
import LLPUtils

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
        case fill(topPadding: CGFloat = .LLPUI.spacing10 * 3, bottomPadding: CGFloat = .LLPUI.spacing10 * 3)
        
        /// The height of the view is not determined by the content, it is always centered
        case centeredVertically(offset: CGFloat = 0)
    }
    
    public var image: UIImage?
    
    public var text: String?
    
    public var detailText: String?
    
    public var action: Action?
    
    public var isLoading: Bool
        
    public var alignment: Alignment
    
    public init(image: UIImage? = nil, text: String? = nil, detailText: String? = nil, action: Action? = nil, isLoading: Bool = false, alignment: Alignment = .fill()) {
        self.image = image
        self.text = text
        self.detailText = detailText
        self.action = action
        self.isLoading = isLoading
        self.alignment = alignment
    }
}
