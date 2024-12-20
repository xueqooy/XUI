//
//  ListCellSizeProviding.swift
//  XUI
//
//  Created by xueqooy on 2023/7/28.
//

import UIKit
import XKit

public struct ListCellSizeOptions: OptionSet {
    /// Configure dummy cell before calculating size
    public static let configureCell = ListCellSizeOptions(rawValue: 1 << 0)

    /// Cache cellSize
    public static let cache = ListCellSizeOptions(rawValue: 1 << 1)

    /// Compress the size to make it as small as possible, only valid when `cellSize`  is `.XUI.automaticDimension` or its width and height are autodimension
    /// By default, the scroll cross axis extent is always consistent with the section container
    public static let compress = ListCellSizeOptions(rawValue: 1 << 2)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public protocol ListCellSizeProviding: AnyObject {
    /// For `ListCellSizeManager` use, determine the acquisition method for `cellSize`
    var cellSizeOptions: ListCellSizeOptions { get }

    /// Use `.XUI.automaticDimension` to use adaptive `cellSize`
    var cellSize: CGSize { get }

    /// It will be automatically set when configuring dummyCell, but for Cells in the list, manual settings as needed
    var layoutContext: ListCellLayoutContext { set get }
}

private let layoutContextAssociation = Association<ListCellLayoutContext>(wrap: .retain)

public extension ListCellSizeProviding {
    var cellSizeOptions: ListCellSizeOptions {
        [.configureCell, .cache]
    }

    var cellSize: CGSize {
        .XUI.automaticDimension
    }

    var layoutContext: ListCellLayoutContext {
        set {
            layoutContextAssociation[self] = newValue
        }
        get {
            layoutContextAssociation[self] ?? .init(scrollDirection: .vertical, sectionScrollCrossAxisExtent: 0)
        }
    }
}
