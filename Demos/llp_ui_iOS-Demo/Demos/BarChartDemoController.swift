//
//  BarChartDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2024/5/5.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI
import LLPUtils

class BarChartDemoController: DemoController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.background1
        
        let notGradedYetLegend = BarChartLegend(color: Colors.disabledText, label: "not graded yet")
        
        let correctLegend = BarChartLegend(color: Colors.green, label: "correct")

        let partialCreditLegend = BarChartLegend(color: Colors.orange, label: "partial credit")

        let incorrectLegend = BarChartLegend(color: Colors.red, label: "incorrect")
        
        let legends = [notGradedYetLegend, correctLegend, partialCreditLegend, incorrectLegend]
        let colors = [Colors.disabledText, Colors.green, Colors.orange, Colors.red]

        func getRandomColor() -> UIColor {
            colors.randomElement() ?? Colors.green
        }
        
        func getRandomLegend() -> BarChartLegend {
            legends.randomElement() ?? correctLegend
        }
        
        
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        
        let intFormatter = NumberFormatter()
        intFormatter.maximumFractionDigits = 0
        
//        addRow(
//            BarChartView {
//                BarChartDataEntry.single(label: "A", color: Colors.green, value: 100)
//            },
//            height: 300, alignment: .fill)
//        
//        addRow(
//            BarChartView {
//                BarChartDataEntry.single(label: "A", color: Colors.green, value: 100)
//
//                BarChartDataEntry.single(label: "B", color: Colors.orange, value: 200)
//            },
//            height: 300, alignment: .fill)
//    
//        addRow(
//            BarChartView(configuration: .init(preferredMaxValue: 1, valueFormatter: percentageFormatter)) {
//                BarChartDataEntry.single(label: "A", color: Colors.green, value: 0.3)
//                
//                BarChartDataEntry.single(label: "B", color: Colors.orange, value: 0.5)
//                
//                BarChartDataEntry.single(label: "C", color: Colors.red, value: 0.2)
//            },
//            height: 300, alignment: .fill)
//        
        let barChart1 = BarChartView(configuration: .init(preferredMaxValue: 1, valueFormatter: percentageFormatter)) {
            BarChartDataEntry.single(label: "0", color: Colors.green, value: 0.3)
            
            BarChartDataEntry.single(label: "1", color: Colors.orange, value: 0.5)
            
            BarChartDataEntry.single(label: "2", color: Colors.red, value: 0.2)
            
            BarChartDataEntry.single(label: "3", color: Colors.disabledText, value: 0.1)
            
            BarChartDataEntry.single(label: "4", color: Colors.green, value: 0)
            
            BarChartDataEntry.single(label: "5", color: Colors.red, value: 1)
        }
        
        addRow(
            barChart1,
            height: 300, alignment: .fill)
        
        addRow(createButton(title: "Update", action: { _ in
            let numberOfEntries = (0...6).randomElement() ?? 3
            barChart1.updateDataEntries(animated: true) {
                for index in (0...numberOfEntries) {
                    BarChartDataEntry.single(label: "\(index)", color: getRandomColor(), value: CGFloat.random(in: 0...1))
                }
            }
        }))
        
        
        let barChart2 = BarChartView(configuration: .init(preferredMaxValue: 50, valueFormatter: intFormatter, legends: legends)) {
            BarChartDataEntry(label: "0") {
                BarChartDataEntry.Item(color: Colors.green, value: 100)
            }
        }
        
        addRow(
            barChart2,
            height: 300, alignment: .fill)
        
        addRow(createButton(title: "Update", action: { _ in
            let numberOfLegends = (0...6).randomElement() ?? 3
            barChart2.configuration.legends = (0...numberOfLegends).map { _ in
                getRandomLegend()
            }
            
            let numberOfEntries = (0...6).randomElement() ?? 3
            barChart2.updateDataEntries(animated: true) {
                for index in (0...numberOfEntries) {
                    BarChartDataEntry(label: "\(index)") {
                        for index in (0...((0..<legends.count).randomElement() ?? 1)) {
                            BarChartDataEntry.Item(color: colors[index], value: CGFloat.random(in: 0...100))
                        }
                    }
                }
            }
        }))
    }
}
