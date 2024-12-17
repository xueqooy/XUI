//
//  BarChartLegend.swift
//  XUI
//
//  Created by xueqooy on 2024/5/10.
//

import Foundation

public struct BarChartLegend: Equatable {
    
    public let color: UIColor
    
    public let label: String
    
    public init(color: UIColor, label: String) {
        self.color = color
        self.label = label
    }
}
