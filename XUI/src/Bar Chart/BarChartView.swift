//
//  BarChartView..swift
//  XUI
//
//  Created by xueqooy on 2024/5/1.
//

import UIKit
import XKit
import Combine
import XKit
import SnapKit

public class BarChartView: UIView, Configurable {
    
    public struct Configuration: Equatable {
        
        /// `preferredMaxValue` should be greater than 0
        public var preferredMaxValue: Double?
        
        public var valueFormatter: NumberFormatter?
        
        public var showsValueLabel: Bool
        
        public var legends: [BarChartLegend]
        
        public var isPopoverEnabled: Bool
                
        public init(preferredMaxValue: Double? = nil, valueFormatter: NumberFormatter? = nil, showsValueLabel: Bool = true, legends: [BarChartLegend] = [], isPopoverEnabled: Bool = true) {
            self.preferredMaxValue = preferredMaxValue
            self.valueFormatter = valueFormatter
            self.showsValueLabel = showsValueLabel
            self.legends = legends
            self.isPopoverEnabled = isPopoverEnabled
        }
    }
    
    public var configuration: Configuration {
        didSet {
            guard oldValue != configuration else { return }
            
            updateConfiguration()
        }
    }
    
    public var dataEntries: [BarChartDataEntry] = [] {
        didSet {
            layoutContext.update(withDataEntries: dataEntries)
            
            setupDataEntryViews(forCount: dataEntries.count)
            configureDataEntryViews()
        }
    }
            
    private let scrollingContainer = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let dataEntryContainer = HStackView(distribution: .equalSpacing)
    
    private let xAxisView = HSeparatorView()
    
    private let legendGroupView = BarChartLegendGroupView()
    
    private let layoutContext: BarChartLayoutContext
        
    private lazy var dataEntryPopover: Popover = {
        var configuration = Popover.Configuration()
        configuration.dismissMode = .tapOnSuperview
        configuration.delayHidingOnAnchor = true
        configuration.preferredDirection = .up
            
        return Popover(configuration: configuration)
    }()
    
    private var scrollingContainerToBottomConstraint: Constraint!
    private var scrollingContainerToLegendSetConstraint: Constraint!
    
    public init(configuration: Configuration, dataEntries: [BarChartDataEntry] = []) {
        layoutContext = BarChartLayoutContext(preferredMaxValue: configuration.preferredMaxValue)
        
        self.configuration = configuration
                
        super.init(frame: .zero)
        
        initialize()
        
        defer {
            self.dataEntries = dataEntries
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutContext.boundingWidth = bounds.width
        
        if !legendGroupView.isHidden, bounds.width > 0 {
            legendGroupView.preferredLayoutWidth = bounds.width
        }
    }
    
    public func updateDataEntries(_ dataEntries: [BarChartDataEntry], animated: Bool = false) {
        if animated {
            if self.dataEntries.count < dataEntries.count {
                // Optimize animation effect when appending items
                setupDataEntryViews(forCount: dataEntries.count)
                layoutIfNeeded()
            }
                        
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
                self.dataEntries = dataEntries
                
                self.layoutIfNeeded()
            }
        } else {
            self.dataEntries = dataEntries
        }
    }
    
    private func initialize() {
        addSubview(legendGroupView)
        legendGroupView.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
        }
        
        addSubview(scrollingContainer)
        scrollingContainer.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            
            scrollingContainerToBottomConstraint = make.bottom.equalToSuperview().constraint
            scrollingContainerToLegendSetConstraint = make.bottom.equalTo(legendGroupView.snp.top).constraint
        }
        
        if !configuration.legends.isEmpty {
            legendGroupView.isHidden = false
            scrollingContainerToLegendSetConstraint.activate()
            scrollingContainerToBottomConstraint.deactivate()
        } else {
            legendGroupView.isHidden = true
            scrollingContainerToLegendSetConstraint.deactivate()
            scrollingContainerToBottomConstraint.activate()
        }
        
        scrollingContainer.addSubview(dataEntryContainer)
        dataEntryContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview().priority(.low)
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        addSubview(xAxisView)
        xAxisView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollingContainer.snp.bottom).inset(BarChartDataEntryView.labelHeight)
        }
        
        updateConfiguration()
    }
    
    private func updateConfiguration() {
        // Preferred max value
        if let preferredMaxValue = configuration.preferredMaxValue, preferredMaxValue <= 0 {
            Asserts.failure("preferredMaxValue should be greater than 0")
        }
        
        layoutContext.preferredMaxValue = configuration.preferredMaxValue
        
        // ValueFormatter, showsValueLabel, isPopoverEnabled
        for case let dataEntryView as BarChartDataEntryView in dataEntryContainer.arrangedSubviews {
            applyStyleConfiguration(to: dataEntryView)
        }
        
        // ShowsLegends
        let showsLegends = !configuration.legends.isEmpty
        if showsLegends == legendGroupView.isHidden {
            if showsLegends {
                legendGroupView.isHidden = false
                scrollingContainerToLegendSetConstraint.activate()
                scrollingContainerToBottomConstraint.deactivate()
            } else {
                legendGroupView.isHidden = true
                scrollingContainerToLegendSetConstraint.deactivate()
                scrollingContainerToBottomConstraint.activate()
            }
        }
        
        legendGroupView.legends = configuration.legends
    }
    
    private func applyStyleConfiguration(to dataEntryView: BarChartDataEntryView) {
        dataEntryView.valueFormatter = configuration.valueFormatter
        dataEntryView.showsValueLabel = configuration.showsValueLabel
        dataEntryView.gestureView.isEnabled = configuration.isPopoverEnabled
    }
    
    private func setupDataEntryViews(forCount count: Int) {
        let previousCount = dataEntryContainer.arrangedSubviews.count
        let diff = count - previousCount
 
        if diff >= 0 {
            (0..<diff).forEach { i in
                // Create data entry view
                let dataEntryView = BarChartDataEntryView(layoutContext: layoutContext)
                dataEntryView.tapAction = { [weak self] in
                    self?.showPopover(from: $0)
                }
                
                dataEntryContainer.addArrangedSubview(dataEntryView)
            }
        } else {
            dataEntryContainer.arrangedSubviews
                .suffix(-diff)
                .forEach { $0.removeFromSuperview() }
        }
    }
    
    private func configureDataEntryViews() {
        for (index, dataEntry) in dataEntries.enumerated() {
            let dataEntryView = (dataEntryContainer.arrangedSubviews[index] as! BarChartDataEntryView)
            
            dataEntryView.dataEntry = dataEntry
            applyStyleConfiguration(to: dataEntryView)
        }
    }
    
    private func showPopover(from dataEntryView: BarChartDataEntryView) {
        guard configuration.isPopoverEnabled, let dataEntry = dataEntryView.dataEntry else { return }
        
        highlightDataEntryView(dataEntryView)

        let label = UILabel(textColor: Colors.title, font: Fonts.caption, numberOfLines: 0)
        label.richText = dataEntry.customPopoverText ?? RichText.dataEntry(dataEntry, valueFormatter: configuration.valueFormatter)

        // Embedding the label in a view can fix sizing issue.
        let contentView = WrapperView(label)
        
        dataEntryPopover.show(contentView, from: dataEntryView.popoverAnchorView) { [weak self] tapPointProvider in
            guard let self else { return true }
            
            // When Popover is currently displayed, if we tap on another dataEntryView, we should immediately switch the display of Popover
            // TODO: Popover cannot achieve this effect as expected, so we need to manually implement this process (much difficult)
            
            guard let pointInContainer = tapPointProvider(self.dataEntryContainer), self.dataEntryContainer.bounds.contains(pointInContainer) else {
                // Without tapping on the container, cancel the highlighting
                self.highlightDataEntryView(nil)
                return true
            }
            
            let originalDataEntryView = dataEntryView
            
            // Find the data entry view that tapped on
            for case let dataEntryView as BarChartDataEntryView in dataEntryContainer.arrangedSubviews  {
                let point = self.dataEntryContainer.convert(pointInContainer, to: dataEntryView.gestureView)
                if dataEntryView.gestureView.bounds.contains(point), dataEntryView != originalDataEntryView {
                    Queue.main.execute(.delay(0.01)) {
                        // At this time, the event delivery has not yet exited. If executed immediately, it will cause the switched popover to immediately hide
                        self.showPopover(from: dataEntryView)
                    }
                    return false
                }
            }
            
            // Unable to find the next dataEntryView tapped on, unhighlight
            self.highlightDataEntryView(nil)
            return true
        }
    }
        
    private func highlightDataEntryView(_ dataEntryView: BarChartDataEntryView?) {
        UIView.animate(withDuration: 0.3) {
            if let target = dataEntryView {
                self.dataEntryContainer.arrangedSubviews.forEach {
                    $0.alpha = $0 == target ? 1 : 0.5
                }
            } else {
                self.dataEntryContainer.arrangedSubviews.forEach {
                    $0.alpha = 1
                }
            }
        }
    }
    
}


// MARK: - Helper

private extension RichText {
    
    static func colorBadge(color: UIColor, text: String) -> RichText {
        RTAttachment(.image(Icons.roundSquare.withTintColor(color), .specified(CGSize(width: 12, height: 12), .center))) + RTSpace(2) + text
    }
    
    
    static func dataEntry(_ dataEntry: BarChartDataEntry, valueFormatter: NumberFormatter?) -> RichText {
        func valueText(for value: Double) -> String {
            return if let valueFormatter {
                valueFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
            } else {
                "\(value)"
            }
        }
        
        return RTSupplement(.font(Fonts.caption), .foreground(Colors.title)) {
            for (index, item) in dataEntry.items.enumerated() {
                colorBadge(color: item.color, text: valueText(for: item.value))
                
                if index != dataEntry.items.count - 1 {
                    RTLineBreak(2)
                }
            }
        }
    }
}
