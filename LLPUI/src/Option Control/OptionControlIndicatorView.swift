//
//  OptionControlIndicatorView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/8.
//

import UIKit
import SnapKit

/// Indicator for `checkbox`, `checkmark` and `radio`
class OptionControlIndicatorView: UIView {
    
    private struct Constants {
        static let cornerRadiusForCheckbox = 6.0
        static let deselectedStrokeWidth = 1.0
        static let selectedStokeWidth = 2.0
        static let animationDuration = 0.1
    }
    
    var isSelected: Bool = false {
        didSet {
            if oldValue == isSelected {
                return
            }
            
            updateState(animated: disablesAnimations ? false : window != nil)
        }
    }
    
    var disablesAnimations: Bool = false
        
    let style: OptionControl.Style
    
    private let backgroundView = BackgroundView()
    private lazy var selectedImageView: UIImageView = {
        var image: UIImage?
        switch style {
        case .checkbox:
            image = Icons.checkmarkThick
        case .checkmark:
            image = Icons.checkmark
        case .radio:
            image = Icons.radioOn
        default:
            fatalError()
        }
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        imageView.image = image
        return imageView
    }()
    
    init(style: OptionControl.Style) {
        self.style = style
        
        super.init(frame: .zero)
        
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(selectedImageView)
        selectedImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        updateState(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        selectedImageView.tintColor = tintColor
        
        updateState(animated: false)
    }
    
    private func updateState(animated: Bool) {
        if animated {
            selectedImageView.isHidden = false
            selectedImageView.layer.animateScale(from: isSelected ? 0.01 : 1.0, to: isSelected ? 1.0 : 0.01, duration: Constants.animationDuration, removeOnCompletion: false) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.selectedImageView.isHidden = !self.isSelected
            }

        } else {
            selectedImageView.isHidden = !isSelected
        }
        
        var backgroundConfiguration = BackgroundConfiguration()
        switch style {
        case .checkbox:
            backgroundConfiguration.cornerStyle = .fixed(Constants.cornerRadiusForCheckbox)
            
            if isSelected {
                backgroundConfiguration.fillColor = tintColor
            } else {
                backgroundConfiguration.strokeWidth = Constants.deselectedStrokeWidth
                backgroundConfiguration.strokeColor = Colors.line2
            }
            
        case .radio:
            backgroundConfiguration.cornerStyle = .capsule
            
            if isSelected {
                backgroundConfiguration.strokeWidth = Constants.selectedStokeWidth
                backgroundConfiguration.strokeColor = tintColor
            } else {
                backgroundConfiguration.strokeWidth = Constants.deselectedStrokeWidth
                backgroundConfiguration.strokeColor = Colors.line2
            }
    
        default: break
        }
    
        backgroundView.configuration = backgroundConfiguration
    }
    
}

