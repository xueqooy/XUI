//
//  PDFFullscreenControlBar.swift
//  XUI
//
//  Created by xueqooy on 2024/12/26.
//

import UIKit
import PDFKit

class PDFFullscreenControlBar: UIView {
    var exitHandler: (() -> Void)?
    var updateDisplayModeHandler: ((PDFDisplayMode) -> Void)?
    
    var displayMode: PDFDisplayMode = .twoUpContinuous {
        didSet {
            updateModeButtonImage()
        }
    }
    
    var numberOfPages: Int = 0 {
        didSet {
            guard oldValue != numberOfPages else { return }
            
            pageChanged()
        }
    }
    
    var currentPageIndex: Int = 0 {
        didSet {
            guard oldValue != currentPageIndex else { return }
            
            pageChanged()
        }
    }
    
    private lazy var modeButton: Button = {
        let button = Button(configuration: .init(imageTransform: CGAffineTransform(rotationAngle: .pi / 2), foregroundColor: .white)) { [weak self] button in
            guard let self else { return }
            
            self.displayMode = displayMode == .singlePageContinuous ? .twoUpContinuous : .singlePageContinuous
            button.configuration.image = displayMode == .singlePageContinuous ? singleColumnImage : doubleColumnImage
            self.updateDisplayModeHandler?(displayMode)
        }
        button.imageTransition = [.fade, .scale]
        button.hitTestSlop = .init(top: -10, left: -6, bottom: -10, right: -6)
        
        return button
    }()
    
    private let pageLabel = UILabel(textColor: .white, font: Fonts.body3Bold, textAlignment: .center)
    
    private lazy var exitButton: Button = {
        let button = Button(image: Icons.collapse, imageSize: .square(20), foregroundColor: .white) { [weak self] _ in
            self?.exitHandler?()
        }
        button.hitTestSlop = .init(top: -10, left: -6, bottom: -10, right: -6)
        return button
    }()
    
    private let doubleColumnImage = UIImage(systemName: "rectangle.grid.2x2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))!
    private let singleColumnImage = UIImage(systemName: "rectangle.grid.1x2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))!
    
    init() {
        super.init(frame: .zero)
        
        let colors = [Colors.darkTeal.withAlphaComponent(0.8), Colors.darkTeal.withAlphaComponent(0)]
        let gradient = BackgroundConfiguration.Gradient(colors: colors, startPoint: .init(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1))
        let backgroundView = BackgroundView(configuration: .init(gradient: gradient))

        addSubview(backgroundView) { make in
            make.edges.equalToSuperview()
        }
        
        let stackView = HStackView(alignment: .center, spacing: .XUI.spacing3) {
            modeButton
            
            HSpacerView.flexible()
                    
            exitButton
        }

        addSubview(stackView) { make in
            make.left.right.equalTo(self.safeAreaLayoutGuide).inset(CGFloat.XUI.spacing3)
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        
        addSubview(pageLabel) { make in
            make.center.equalTo(stackView)
        }
        
        updateModeButtonImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateModeButtonImage() {
        modeButton.configuration.image = displayMode == .singlePageContinuous ? singleColumnImage : doubleColumnImage
    }
    
    private func pageChanged() {
        modeButton.isHidden = numberOfPages <= 1

        if numberOfPages > 1 {
            pageLabel.isHidden = false
            pageLabel.text = "\(currentPageIndex + 1) / \(numberOfPages)"
        } else {
            pageLabel.isHidden = true
        }
    }
}
