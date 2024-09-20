//
//  ListSectionBackgroundConfigurationProviding.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/15.
//

import Foundation

/// Background configuration of all items in the section
public protocol ListSectionBackgroundConfigurationProviding {
    var sectionBackgroundConfiguration: BackgroundConfiguration? { get }
    var sectionBackgroundInset: Insets { get }
}

public extension ListSectionBackgroundConfigurationProviding {
    var sectionBackgroundConfiguration: BackgroundConfiguration? { nil }
    var sectionBackgroundInset: Insets { .nondirectionalZero }
}
