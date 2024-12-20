//
//  BarChartView+DSL.swift
//  XUI
//
//  Created by xueqooy on 2024/5/5.
//

import UIKit
import XKit

public extension BarChartView {
    convenience init(configuration: Configuration = .init(), @ArrayBuilder<BarChartDataEntry> dataEntries: () -> [BarChartDataEntry]) {
        self.init(configuration: configuration, dataEntries: dataEntries())
    }

    func updateDataEntries(animated: Bool = false, @ArrayBuilder<BarChartDataEntry> dataEntries: () -> [BarChartDataEntry]) {
        updateDataEntries(dataEntries(), animated: animated)
    }
}

public extension BarChartDataEntry {
    init(label: String, customPopoverText: RichText? = nil, @ArrayBuilder<BarChartDataEntry.Item> items: () -> [BarChartDataEntry.Item]) {
        self.init(label: label, items: items(), customPopoverText: customPopoverText)
    }
}
