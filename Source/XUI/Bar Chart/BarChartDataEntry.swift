//
//  BarChartDataEntry.swift
//  XUI
//
//  Created by xueqooy on 2024/5/5.
//

import UIKit

public struct BarChartDataEntry: Equatable {
    public struct Item: Equatable {
        public let color: UIColor

        public let value: Double

        public init(color: UIColor, value: Double) {
            self.color = color
            self.value = value
        }
    }

    public let label: String

    public let items: [Item]

    public let customPopoverText: RichText?

    public init(label: String, items: [Item], customPopoverText: RichText? = nil) {
        self.label = label
        self.items = items
        self.customPopoverText = customPopoverText
    }

    public static func single(label: String, color: UIColor, value: Double, customPopoverText: RichText? = nil) -> Self {
        .init(label: label, items: [.init(color: color, value: value)], customPopoverText: customPopoverText)
    }
}

public extension BarChartDataEntry {
    var value: Double {
        items.reduce(0) { $0 + $1.value }
    }
}
