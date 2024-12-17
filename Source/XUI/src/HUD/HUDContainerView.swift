//
//  HUDContainerView.swift
//  XUI
//
//  Created by xueqooy on 2024/3/13.
//

import UIKit

class HUDContainerView: UIView {
    
    var isInteractionEnabled: Bool = false {
        didSet {
            guard isInteractionEnabled != oldValue else {
                return
            }

            updateBackground()
        }
    }
    
    public var contentView: UIView? {
        willSet {
            guard newValue !== contentView else { return }
            
            contentView?.removeFromSuperview()
        }
        
        didSet {
            guard contentView !== oldValue, let contentView else {
                return
            }
            
            contentStackView.insertArrangedSubview(contentView, at: 0)
        }
    }
    
    public var actionTitle: String? {
        didSet {
            guard oldValue != actionTitle else { return }
            
            if let actionTitle, !actionTitle.isEmpty {
                actionButton.configuration.title = actionTitle
                
                if actionContaienrView.superview !== contentStackView {
                    contentStackView.insertArrangedSubview(actionContaienrView, at: contentStackView.arrangedSubviews.count)
                }
                
            } else {
                actionContaienrView.removeFromSuperview()
            }
        }
    }
    
    public var actionHandler: (() -> Void)?
    
    
    private let dimmingBackgroundView: BackgroundView = {
        var configuration = BackgroundConfiguration()
        configuration.visualEffect = UIBlurEffect(style: .light)
        
        let backgroundView = BackgroundView(configuration: configuration)
        backgroundView.isUserInteractionEnabled = true
        return backgroundView
    }()
    
    private let contentBackgroundView: BackgroundView = {
        var configuration = BackgroundConfiguration.overlay(color: .clear)
        configuration.visualEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        let backgroundView = BackgroundView(configuration: configuration)
        backgroundView.isUserInteractionEnabled = true
        
        return backgroundView
    }()
        
    private let contentStackView = VStackView(spacing: .XUI.spacing5, layoutMargins: .init(uniformValue: .XUI.spacing5))
    
    private lazy var actionButton = Button(designStyle: .primary, contentInsetsMode: .override(.nondirectional(top: 6, left: 20, bottom: 6, right: 20))) { [weak self] _ in
        self?.actionHandler?()
    }
    
    private lazy var actionContaienrView = AlignedContainerView(actionButton, alignment: .centerHorizontally)
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(dimmingBackgroundView)
        dimmingBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(contentBackgroundView)
        contentBackgroundView.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview().offset(-CGFloat.XUI.spacing10)
            make.height.lessThanOrEqualToSuperview().offset(-CGFloat.XUI.spacing10)
            make.center.equalToSuperview()
        }
        
        
        contentBackgroundView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        updateBackground()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateBackground() {
        dimmingBackgroundView.alpha = isInteractionEnabled ? 0 : .XUI.dimmingAlpha
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isInteractionEnabled {
            return contentBackgroundView.frame.contains(point)
        } else {
            return super.point(inside: point, with: event)
        }
    }
}
