//
//  ListSectionInnerBackgroundConfigurationProviding.swift
//  XUI
//
//  Created by xueqooy on 2023/11/10.
//

import Foundation
import XUI

/// Background configuration of specified  items in the section, continuous items will be integrated into a background
public protocol ListSectionInnerBackgroundConfigurationProviding {
    var sectionInnerBackgroundItems: Set<Int>? { get }
    func sectionInnerBackgroundConfiguration(for range: Range<Int>) -> BackgroundConfiguration?
    func sectionInnerBackgroundInset(for range: Range<Int>) -> Insets
}

public extension ListSectionInnerBackgroundConfigurationProviding {
    var sectionInnerBackgroundItems: Set<Int>? { nil }
    func sectionInnerBackgroundConfiguration(for _: Range<Int>) -> BackgroundConfiguration? { nil }
    func sectionInnerBackgroundInset(for _: Range<Int>) -> Insets { .nondirectionalZero }
}
