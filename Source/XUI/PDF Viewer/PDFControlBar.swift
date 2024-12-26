//
//  PDFControlBar.swift
//  XUI
//
//  Created by xueqooy on 2024/12/26.
//

import UIKit

class PDFControlBar: UIView {
    var numberOfPages: Int = 0 {
        didSet {
            guard oldValue != numberOfPages else { return }
            
            updatePageLabel()
            updatePageSlider()
        }
    }
    
    var currentPageIndex: Int = 0 {
        didSet {
            guard oldValue != currentPageIndex else { return }
            
            updatePageLabel()
            if !pageSliderDragging {
                updatePageSlider()
            }
        }
    }
    
    var minScaleFactor: CGFloat = 0 {
        didSet {
            guard oldValue != minScaleFactor else { return }
            
            scaleFactorSlider.minimumValue = Float(minScaleFactor)
        }
    }
    
    var maxScaleFactor: CGFloat = 0 {
        didSet {
            guard oldValue != maxScaleFactor else { return }
            
            scaleFactorSlider.maximumValue = Float(maxScaleFactor)
        }
    }
    
    var currentScaleFactor: CGFloat = 0 {
        didSet {
            guard oldValue != currentScaleFactor, !scaleFactorSliderDragging else { return }
            
            scaleFactorSlider.value = Float(currentScaleFactor)
        }
    }

    
    var goPageHandler: ((Int) -> Void)?
    var updateScaleFactorHandler: ((CGFloat) -> Void)?
    var fullscreenHandler: (() -> Void)?
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 31)
    }
    
    private let pageLabel = UILabel(textColor: .white, font: Fonts.caption)
    private let pageSlider = PDFControlSlider(type: .page)
    private let scaleFactorSlider = PDFControlSlider(type: .scaleFactor)
    private let fullscreenButton = Button(image: Icons.expand, imageSize: .square(14), foregroundColor: .white)
    
    private var hapticFeedback: HapticFeedback?
    private var pageSliderDragging = false
    private var scaleFactorSliderDragging = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        backgroundColor = Colors.darkTeal

        let stackView = HStackView(alignment: .center, spacing: .XUI.spacing2) {
            pageLabel
            pageSlider
            scaleFactorSlider
            fullscreenButton
        }
        addSubview(stackView) { make in
            make.left.right.equalToSuperview().inset(CGFloat.XUI.spacing2)
            make.top.bottom.equalToSuperview()
        }
        
        pageSlider.addTarget(self, action: #selector(Self.startDragging(_:)), for: .touchDown)
        pageSlider.addTarget(self, action: #selector(Self.endDragging(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        pageSlider.addTarget(self, action: #selector(Self.valueChanged(_:)), for: .valueChanged)
        
        scaleFactorSlider.addTarget(self, action: #selector(Self.startDragging(_:)), for: .touchDown)
        scaleFactorSlider.addTarget(self, action: #selector(Self.endDragging(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        scaleFactorSlider.addTarget(self, action: #selector(Self.valueChanged(_:)), for: .valueChanged)
        
        fullscreenButton.touchUpInsideAction = { [weak self] _ in
            self?.fullscreenHandler?()
        }
    }
    
    private func updatePageLabel() {
        pageLabel.text = "\(currentPageIndex + 1) / \(numberOfPages)"
    }
    
    private func updatePageSlider() {
        if numberOfPages <= 2 {
            pageSlider.isEnabled = false
            pageSlider.maximumValue = 1
            pageSlider.value = 1
        } else {
            pageSlider.isEnabled = true
            // numberOfPages: 3 4 5 6 7 8 9 10
            // maximumValue : 1 1 2 2 3 3 4 4
            pageSlider.maximumValue = Float((numberOfPages - 1) / 2)
            // currentPageIndex: 0 1 2 3 4 5 6 7
            // value           : 0 0 1 1 2 2 3 3
            pageSlider.value = Float(currentPageIndex / 2)
        }
    }
    
    @objc private func startDragging(_ slider: PDFControlSlider) {
        if slider === pageSlider {
            pageSliderDragging = true
            hapticFeedback = HapticFeedback(type: .light)
            hapticFeedback!.prepare()
            
        } else if slider === scaleFactorSlider {
            scaleFactorSliderDragging = true
        }
    }
    
    @objc private func valueChanged(_ slider: PDFControlSlider) {
        if slider === pageSlider {
            let expectedPageIndex = Int(round(pageSlider.value)) * 2
            
            if currentPageIndex != expectedPageIndex {
                currentPageIndex = expectedPageIndex
                hapticFeedback?.trigger()
                
                goPageHandler?(expectedPageIndex)
            }
            
        } else if slider === scaleFactorSlider {
            updateScaleFactorHandler?(CGFloat(slider.value))
        }
    }
    
    @objc private func endDragging(_ slider: PDFControlSlider) {
        if slider === pageSlider {
            pageSliderDragging = false
            hapticFeedback = nil

            let expectedPageIndex = Int(round(pageSlider.value)) * 2
            pageSlider.value = Float(expectedPageIndex / 2)
            
        } else if slider === scaleFactorSlider {
            scaleFactorSliderDragging = false
        }
    }
}
