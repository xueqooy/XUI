//
//  AvatarURLConfiguration.swift
//  XUI
//
//  Created by xueqooy on 2023/10/19.
//

import Foundation
import XKit

public struct AvatarURLConfiguration: Hashable, Then {
    public static let empty: AvatarURLConfiguration = .init()

    public var preferredURL: URL?
    public var alternativeURL: URL?

    public init(preferredURL: URL? = nil, alternativeURL: URL? = nil) {
        self.preferredURL = preferredURL
        self.alternativeURL = alternativeURL
    }
}
