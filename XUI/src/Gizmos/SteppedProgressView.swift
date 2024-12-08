//
//  SteppedProgressView.swift
//  XUI
//
//  Created by xueqooy on 2023/3/10.
//

import UIKit
import SnapKit

public class SteppedProgressView: UIView {
    
    private struct Constants {
        static let instrinsicHeight = 34.0
        static let stepLabelSize = CGSize(width: 34, height: 34)
        static let lineHeight = 2.0
    }
    
    public var numberOfSteps: Int = 0 {
        didSet {
            if oldValue == numberOfSteps {
                return
            }
            
            layoutViews()
            updateBackgroundColorOfViews()
        }
    }
    public var currentStep: Int = 0 {
        didSet {
            if oldValue == currentStep {
                return
            }
            
            updateBackgroundColorOfViews()
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            if oldValue.width == bounds.width {
                return
            }
            
            setNeedsUpdateConstraints()
        }
    }

    private var views = [UIView]()
    private var lineWidthConstraints = [Constraint]()
        
    public init(numberOfSteps: Int = 0, currentStep: Int = 0) {
        super.init(frame: .zero)
      
        defer {
            self.numberOfSteps = numberOfSteps
            self.currentStep = currentStep
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        defer {
            self.numberOfSteps = 0
            self.currentStep = 0
        }
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        if lineWidthConstraints.isEmpty {
            return
        }
                
        let lineWidth = max((bounds.width - CGFloat(numberOfSteps) * Constants.stepLabelSize.width) / (CGFloat(numberOfSteps) - 1), 0)
        lineWidthConstraints.forEach { widthConstraint in
            widthConstraint.update(offset: lineWidth)
        }
    }
    
    private func createStepLabel(_ number: Int) -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.body1Bold
        label.textAlignment = .center
        label.text = "\(number)"
        label.layer.cornerRadius = Constants.stepLabelSize.height * 0.5
        label.layer.masksToBounds = translatesAutoresizingMaskIntoConstraints
        label.clipsToBounds = true
        return label
    }

    private func layoutViews() {
        views.forEach { $0.removeFromSuperview() }
        
        var layoutReferenceView: UIView?
        for i in 0..<numberOfSteps {
            let stepLabel = createStepLabel(i + 1)
            addSubview(stepLabel)
            stepLabel.snp.makeConstraints { make in
                make.size.equalTo(Constants.stepLabelSize)
                make.centerY.equalToSuperview()
                if let layoutReferenceView = layoutReferenceView {
                    make.leading.equalTo(layoutReferenceView.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
                if i == numberOfSteps - 1 {
                    make.trailing.equalToSuperview()
                }
            }
            layoutReferenceView = stepLabel

            views.append(stepLabel)
                        
            if i != numberOfSteps - 1 {
                let lineView = UIView()
                addSubview(lineView)
                lineView.snp.makeConstraints { make in
                    make.height.equalTo(Constants.lineHeight)
                    make.centerY.equalToSuperview()
                    make.leading.equalTo(layoutReferenceView!.snp.trailing)
                    lineWidthConstraints.append(make.width.equalTo(0).priority(.low).constraint)
                }
                layoutReferenceView = lineView

                views.append(lineView)
            }
        }
    }
    
    private func updateBackgroundColorOfViews() {
        let highlightedViewCount = currentStep * 2 + 1
        
        for (index, view) in views.enumerated() {
            view.backgroundColor = index < highlightedViewCount ? Colors.teal : .init(colorValue: .with8Bit(r: 210, g: 215, b: 224, a: 1))

        }
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Constants.instrinsicHeight)
    }
}
