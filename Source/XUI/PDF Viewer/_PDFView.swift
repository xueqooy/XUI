//
//  _PDFView.swift
//  XUI
//
//  Created by xueqooy on 2024/12/26.
//

import PDFKit
import UIKit
import Combine

class _PDFView: PDFView {
    
    override var displayMode: PDFDisplayMode {
        didSet {
            guard oldValue != displayMode else { return }
            
            let shoudShowButtons = displayMode == .twoUp || displayMode == .singlePage
            nextButton.isHidden = !shoudShowButtons
            prevButton.isHidden = !shoudShowButtons
            
            updateScaleFactor(setsCurrentToMin: true)
        }
    }
    
    override var document: PDFDocument? {
        didSet {
            if let documentView = documentView {
                documentViewObserver.addToView(documentView)
            } else {
                documentViewObserver.removeFromView()
            }
            
            updateScaleFactor(setsCurrentToMin: true)
        }
    }
    
    var scaleChangedHandler: (() -> Void)?
    var pageChangedHandler: (() -> Void)?
    
    private let prevButton = Button(image: Icons.arrowLargeRight, imageTransform: CGAffineTransform(rotationAngle: .pi), foregroundColor: .white)
        .then {
            $0.hitTestSlop = .init(top: 0, left: -5, bottom: 0, right: -5)
        }
    private let nextButton = Button(image: Icons.arrowLargeRight, foregroundColor: .white)
        .then {
            $0.hitTestSlop = .init(top: 0, left: -5, bottom: 0, right: -5)
        }
    
    private var documentViewObserver = ViewLayoutPropertyObserver(properties: .center)
    private var observations = [AnyCancellable]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        displayDirection = .horizontal
        displayMode = .twoUp
        backgroundColor = Colors.bodyText1
        
        addSubview(prevButton) { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(CGFloat.XUI.spacing3)
        }
         
        addSubview(nextButton) { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(CGFloat.XUI.spacing3)
        }
        
        prevButton.touchUpInsideAction = { [weak self] _ in
            self?.goToPreviousPage(nil)
        }
        
        nextButton.touchUpInsideAction = { [weak self] _ in
            self?.goToNextPage(nil)
        }
        
        // Observe the scale change
        documentViewObserver.propertyDidChangePublisher
            .sink { [weak self] _ in
                self?.scaleChanged()
            }
            .store(in: &observations)
        
        // Observe the page change
        NotificationCenter.default.publisher(for: .PDFViewPageChanged, object: self)
            .sink { [weak self] _  in
                self?.pageChanged()
            }
            .store(in: &observations)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bringSubviewToFront(prevButton)
        bringSubviewToFront(nextButton)
    }
    
    func updateScaleFactor(setsCurrentToMin: Bool = false) {
        func calculateMinScaleFactor() -> CGFloat {
            guard let document, let firstPage = document.page(at: 0) else { return 1 }
            let pageSize = firstPage.bounds(for: displayBox).size
            let spacing = 2.0
            let boundingWidth = bounds.width - 2 * spacing
            let boundingHeight = bounds.height - 2 * spacing
            let size = if document.pageCount == 1 || displayMode == .singlePage || displayMode == .singlePageContinuous {
                // Display one column
                pageSize
            } else {
                // Display two columns
                CGSize(width: pageSize.width * 2 + spacing, height: pageSize.height)
            }
            
            let widthScale = boundingWidth / size.width
            let heightScale = boundingHeight / size.height
            
            return min(widthScale, heightScale)
        }
        
        minScaleFactor = calculateMinScaleFactor()
        maxScaleFactor = 1.5
        
        if setsCurrentToMin {
            scaleFactor = minScaleFactor
        }
    }
    
    private func pageChanged() {
        nextButton.configuration.foregroundColor = .init(white: 1, alpha: canGoToNextPage ? 1 : 0)
        prevButton.configuration.foregroundColor = .init(white: 1, alpha: canGoToPreviousPage ? 1 : 0)
        
        pageChangedHandler?()
    }
    
    private func scaleChanged() {
        if scaleFactor - minScaleFactor > 0.01 {
            if prevButton.alpha != 0 {
                [prevButton, nextButton].forEach { button in
                    button.alpha = 0
                    button.layer.animateAlpha(from: 1, to: 0, duration: 0.25)
                }
            }
        } else {
            if prevButton.alpha == 0 {
                [prevButton, nextButton].forEach { button in
                    button.alpha = 1
                    button.layer.animateAlpha(from: 0, to: 1, duration: 0.25)
                }
            }
        }
        
        scaleChangedHandler?()
    }
}
