//
//  PopoverContainerView.swift
//  XUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit

class PopoverContainerView: UIView {

    var positionController: PopoverPositionController? {
        didSet {
            arrowImageView.transform = transformForArrowImageView()
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private let contentView: UIView
    private let configuration: Popover.Configuration
    
    private let backgroundView: BackgroundView
    private let arrowImageViewBaseImage: UIImage?
    private let arrowImageView: UIImageView
    
    init(contentView: UIView, configuration: Popover.Configuration) {
        self.contentView = contentView
        self.configuration = configuration
        
        backgroundView = BackgroundView(configuration: configuration.background)
        
        arrowImageViewBaseImage = Icons.popoverArrowUp
        arrowImageView = UIImageView(image: arrowImageViewBaseImage)
        arrowImageView.tintColor = configuration.background.fillColor
    
        super.init(frame: .zero)
        
        addSubview(backgroundView)
        
        addSubview(arrowImageView)

        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        
        guard let positionController = positionController else {
            return
        }
        
        if positionController.arrowPosition.isVertical {
            arrowImageView.frame.size = configuration.arrowSize
            arrowImageView.frame.origin.x = positionController.arrowOffset
            backgroundView.frame.size.height -= arrowImageView.frame.height
        } else {
            arrowImageView.frame.size = CGSize(width: configuration.arrowSize.height, height: configuration.arrowSize.width)
            arrowImageView.frame.origin.y = positionController.arrowOffset
            backgroundView.frame.size.width -= arrowImageView.frame.width
        }

        switch positionController.arrowPosition {
        case .top:
            arrowImageView.frame.origin.y = 0.0
            backgroundView.frame.origin.y = arrowImageView.frame.maxY
        case .bottom:
            arrowImageView.frame.origin.y = bounds.height - arrowImageView.frame.height
        case .left:
            arrowImageView.frame.origin.x = 0.0
            backgroundView.frame.origin.x = arrowImageView.frame.maxX
        case .right:
            arrowImageView.frame.origin.x = bounds.width - arrowImageView.frame.width
        }

        contentView.frame = backgroundView.frame.inset(by: configuration.contentInsets)
    }
    
    private func transformForArrowImageView() -> CGAffineTransform {
        switch positionController?.arrowPosition {
        case .top:
            return .identity
        case .bottom:
            return CGAffineTransform(rotationAngle: .pi)
        case .left:
            return CGAffineTransform(rotationAngle: .pi * 1.5)
        case .right:
            return CGAffineTransform(rotationAngle: .pi * 0.5)
        case .none:
            return .identity
        }
    }
}
