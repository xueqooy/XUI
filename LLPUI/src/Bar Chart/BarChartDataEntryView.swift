//
//  BarChartDataEntryView.swift
//  LLPUI
//
//  Created by xueqooy on 2024/5/4.
//

import UIKit
import SnapKit
import Combine

class BarChartDataEntryView: UIView, UIGestureRecognizerDelegate {
    
    static let valueTextHeight: CGFloat = 24
    
    static let labelHeight: CGFloat = 44
        
    var dataEntry: BarChartDataEntry? {
        didSet {
            guard dataEntry != oldValue else { return }
            
            updateBarAndLabel()
            updateBarHeight()
            updateValueText()
        }
    }
            
    var valueFormatter: NumberFormatter? {
        didSet {
            guard valueFormatter != oldValue else { return }
            
            updateValueText()
        }
    }
    
    var showsValueLabel: Bool {
        set {
            guard showsValueLabel != newValue else { return }
            
            valueLabel.isHidden = !newValue
            
            if !newValue {
                popoverAnchorTopToValueConstraint.deactivate()
                popoverAnchorTopToBarConstraint.activate()
            } else {
                popoverAnchorTopToBarConstraint.deactivate()
                popoverAnchorTopToValueConstraint.activate()
            }
        }
        get {
            !valueLabel.isHidden
        }
    }
    
    var tapAction: ((BarChartDataEntryView) -> Void)?
        
    let popoverAnchorView = UIView()
    
    let gestureView = UIControl()

    private let barView = BarView()
    
    private let layoutContext: BarChartLayoutContext
    
    private let barLabel = UILabel(textColor: Colors.title, font: Fonts.body2Bold, textAlignment: .center, numberOfLines: 0)
        .settingContentCompressionResistancePriority(.fittingSizeLevel)

    private let valueLabel = UILabel(textColor: Colors.title, font: Fonts.caption, textAlignment: .center, numberOfLines: 0)
        .settingContentCompressionResistancePriority(.fittingSizeLevel)
    
    
    private var barHeightConstraint: Constraint!
    
    private var popoverAnchorTopToValueConstraint: Constraint!
    private var popoverAnchorTopToBarConstraint: Constraint!

    private var validBarHeight: CGFloat?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(layoutContext: BarChartLayoutContext) {
        self.layoutContext = layoutContext
        
        super.init(frame: .zero)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        addSubview(barView)
        barView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(Self.labelHeight)
            barHeightConstraint = make.height.equalTo(0).constraint
        }
        
        addSubview(barLabel)
        barLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(CGFloat.LLPUI.spacing1)
            make.bottom.equalToSuperview()
            make.height.equalTo(Self.labelHeight)
        }
        
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(CGFloat.LLPUI.spacing1)
            make.bottom.equalTo(barView.snp.top)
            make.height.equalTo(Self.valueTextHeight)
        }
        
        popoverAnchorView.isUserInteractionEnabled = false
        addSubview(popoverAnchorView)
        popoverAnchorView.snp.makeConstraints { make in
            make.width.equalTo(barView)
            popoverAnchorTopToValueConstraint = make.top.equalTo(valueLabel).constraint
            popoverAnchorTopToBarConstraint = make.top.equalTo(barView).constraint
            make.bottom.equalTo(barLabel)
            make.centerX.equalToSuperview()
        }
        
        popoverAnchorTopToBarConstraint.deactivate()
        
        addSubview(gestureView)
        gestureView.snp.makeConstraints { make in
            make.width.equalTo(barView)
            make.top.bottom.centerX.equalToSuperview()
        }
        
        updateBarAndLabel()
        
        // Bindings
        layoutContext.$maxValue.didChange
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateBarHeight()
            }
            .store(in: &cancellables)
        
        layoutContext.$spacing.didChange
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.invalidateIntrinsicContentSize()
            }
            .store(in: &cancellables)
        
        gestureView.addTarget(self, action: #selector(Self.gestureAction), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        updateBarHeight()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: layoutContext.spacing.value, height: UIView.noIntrinsicMetric)
    }
    
    private func updateBarAndLabel() {
        barView.dataEntry = dataEntry
        barLabel.text = dataEntry?.label
    }
    
    private func updateBarHeight() {
        guard let dataEntry else { return }
        
        let multiplier = dataEntry.value / layoutContext.maxValue
        let barHeight = max(0, bounds.height - Self.labelHeight - Self.valueTextHeight) * multiplier
          
        if let validBarHeight, validBarHeight == barHeight {
            return
        }
    
        self.validBarHeight = barHeight
        
        barHeightConstraint.update(offset: barHeight)
    }
    
    private func updateValueText() {
        guard let dataEntry else { return }
        
        if let valueFormatter = valueFormatter {
            valueLabel.text = valueFormatter.string(from: NSNumber(value: dataEntry.value))
        } else {
            valueLabel.text = "\(dataEntry.value)"
        }
    }
    
    @objc private func gestureAction() {
        tapAction?(self)
    }
}


// MARK: - Bar View

private class BarView: UIView {
    
    var dataEntry: BarChartDataEntry? {
        didSet {
            update()
        }
    }
    
    private var container = VStackView(distribution: .fillProportionally)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: 24, height: UIView.noIntrinsicMetric)
    }
    
    private func initialize() {
        layer.cornerRadius = 4
        layer.masksToBounds = true
        isUserInteractionEnabled = false
                    
        addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func update() {
        let items = dataEntry?.items ?? []
        
        let previousCount = container.arrangedSubviews.count
        let diff = items.count - previousCount
 
        if diff >= 0 {
            (0..<diff).forEach { i in
                // The purpose of setting the initial size is to optimize the animation
                let initialSize = bounds.size
                let itemView = BarItemView(frame: .init(origin: .zero, size: initialSize))
                                            
                container.addArrangedSubview(itemView)
            }
        } else {
            container.arrangedSubviews
                .prefix(-diff)
                .forEach { $0.removeFromSuperview() }
        }
        
        for (index, item) in items.enumerated() {
            let view = (container.arrangedSubviews[index] as! BarItemView)
            
            view.item = item
        }
        
        // optimize the animation
        backgroundColor = items.first?.color
    }
}


// MARK: - Bar View

private class BarItemView: UIView {
    
    var item: BarChartDataEntry.Item? {
        didSet {
            guard oldValue != item else { return }
            
            backgroundColor = item?.color
            
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let value = item?.value ?? 0
        
        return CGSize(width: UIView.noIntrinsicMetric, height: value * 100)
    }
}
