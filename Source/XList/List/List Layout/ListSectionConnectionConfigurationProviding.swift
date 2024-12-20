//
//  ListSectionConnectionConfigurationProviding.swift
//  XUI
//
//  Created by xueqooy on 2023/10/5.
//

import Foundation
import UIKit

public struct ListSectionConnectionConfiguration: Equatable {
    public enum Role {
        case parent, child
    }

    public struct Anchor: Equatable {
        public let relativePosition: CGPoint
        public let offset: UIOffset

        public init(relativePosition: CGPoint, offset: UIOffset) {
            self.relativePosition = relativePosition
            self.offset = offset
        }

        func point(for rect: CGRect) -> CGPoint {
            let x = rect.origin.x + offset.horizontal + rect.width * relativePosition.x
            let y = rect.origin.y + offset.vertical + rect.height * relativePosition.y
            return .init(x: x, y: y)
        }
    }

    public let role: Role
    public let anchor: Anchor

    public init(role: Role, anchor: Anchor) {
        self.role = role
        self.anchor = anchor
    }
}

public protocol ListSectionConnectionConfigurationProviding {
    var sectionConnectionConfiguration: ListSectionConnectionConfiguration? { get }
}

public extension ListSectionConnectionConfigurationProviding {
    var sectionConnectionConfiguration: ListSectionConnectionConfiguration? { nil }
}
