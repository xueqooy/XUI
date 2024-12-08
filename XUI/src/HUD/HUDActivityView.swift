//
//  HUDActivityView.swift
//  XUI
//
//  Created by xueqooy on 2024/3/14.
//

import UIKit

class HUDActivityView: UIView {

    var text: String? {
        get {
            textLabel.text
        }
        set {
            let hasText = newValue != nil && newValue?.isEmpty == false
            
            textLabel.isHidden = !hasText
            textLabel.text = newValue
        }
    }
    
    private let imageView = UIImageView(image: Icons.hudActivity)
    
    private lazy var textLabel = UILabel(textStyleConfiguration: .hudText, numberOfLines: 0)
    
    private let animationKey = "Rotation"
    private let animationKeyPath = "transform.rotation.z"

    override init(frame: CGRect) {
        super.init(frame: frame)

        let stack = VStackView(alignment: .center, spacing: .XUI.spacing3) {
            imageView
            
            textLabel
                .settingHidden(true)
        }
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        checkAnimation()
    }
    
    private func checkAnimation() {
        let isVisible = window != nil && superview != nil && !isHidden && alpha > 0
        
        if isVisible {
            guard imageView.layer.animation(forKey: animationKey) == nil else { return }
            
            var fromValue = CGFloat.pi
            let presentationLayer = imageView.layer.presentation()
            if let value = presentationLayer?.value(forKey: animationKeyPath) as? CGFloat {
                fromValue = value
            }
            
            let animation = CABasicAnimation(keyPath: animationKeyPath)
            animation.duration = 1.5
            animation.fromValue = fromValue
            animation.toValue = fromValue + .pi * 2
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.beginTime = 0
            
            imageView.layer.add(animation, forKey: animationKey)
    
        } else {
            imageView.layer.removeAnimation(forKey: animationKey)
        }
    }
}
