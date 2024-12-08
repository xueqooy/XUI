//
//  BarChartLayoutContext.swift
//  XUI
//
//  Created by xueqooy on 2024/5/5.
//

import Foundation
import XKit

class BarChartLayoutContext {
        
    enum LayoutSpacing: Equatable {
        case compact
        case regular
        
        var value: CGFloat {
            switch self {
            case .compact:
                72
                
            case .regular:
                104
            }
        }
    }
    
    @EquatableState
    private(set) var maxValue: Double = 1
    
    @EquatableState
    private(set) var spacing: LayoutSpacing = .regular
    
    public var boundingWidth: CGFloat = 0 {
        didSet {
            updateStyle()
        }
    }
    
    public var preferredMaxValue: Double? {
        didSet {
            guard preferredMaxValue != oldValue else { return }
            
            if let preferredMaxValue, preferredMaxValue <= 0 {
                self.preferredMaxValue = nil
            }
            
            updateMaxValue()
        }
    }
    
    private var maxValueOfDataEntries: Double? {
        didSet {
            updateMaxValue()
        }
    }
    
    private var numberOfDataEntries: Int = 0 {
        didSet {
            updateStyle()
        }
    }
    
    init(preferredMaxValue: Double? = nil) {
        if let preferredMaxValue, preferredMaxValue > 0 {
            self.preferredMaxValue = preferredMaxValue
            self.maxValue = preferredMaxValue
        }
    }
    
    func update(withDataEntries dataEntries: [BarChartDataEntry]) {
        maxValueOfDataEntries = dataEntries.map(\.value).max()

        numberOfDataEntries = dataEntries.count
    }
    
    private func updateMaxValue() {
        if var maxValue = maxValueOfDataEntries {
            if let preferredMaxValue {
                maxValue = max(preferredMaxValue, maxValue)
            }
            
            self.maxValue = maxValue > 0 ? maxValue : 1
        } else {
            maxValue = preferredMaxValue ?? 1
        }
    }
    
    private func updateStyle() {
        let regularTotalWidth = CGFloat(numberOfDataEntries) * LayoutSpacing.regular.value
        
        if regularTotalWidth <= boundingWidth {
            spacing = .regular
        } else {
            spacing = .compact
        }
    }
}
