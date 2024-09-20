//
//  AvatarGroupView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/19.
//

import UIKit

public class AvatarGroupView: UIView {
    
    private struct Constants {
        static let overlapWidth: CGFloat = .LLPUI.spacing2
    }
    
    public var urlConfigurations = [AvatarURLConfiguration]() {
        didSet {
            guard urlConfigurations != oldValue else {
                return
            }
            
            if urlConfigurations.count == oldValue.count {
                update()
            } else {
                layout()
                update()
                
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    public let avatarSize: AvatarSize
    
    /// Less than or equal to 0 means no limit
    public var maximumNumberOfDisplays = 0 {
        didSet {
            guard maximumNumberOfDisplays != oldValue else {
                return
            }
            
            layout()
            update()
            
            invalidateIntrinsicContentSize()
        }
    }
    
    private var numberOfDisplays: Int {
        if maximumNumberOfDisplays <= 0 {
            return urlConfigurations.count
        } else {
            return max(0, min(maximumNumberOfDisplays, urlConfigurations.count))
        }
    }
    
    private var avatarViews = [AvatarView]()
    
    private var shouldShowFadeLayer: Bool {
        maximumNumberOfDisplays > 0 ? urlConfigurations.count > maximumNumberOfDisplays : false
    }

    private let fadeLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()
    
    public init(avatarSize: AvatarSize = .size24, maximumNumberOfDisplays: Int = 0, urlConfigurations: [AvatarURLConfiguration] = []) {
        self.avatarSize = avatarSize
        self.maximumNumberOfDisplays = maximumNumberOfDisplays
        
        super.init(frame: .zero)
        
        defer {
            self.urlConfigurations = urlConfigurations
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if shouldShowFadeLayer, let lastAvatarView = avatarViews.last {
            fadeLayer.frame = lastAvatarView.bounds
        }
    }
    
    private func layout() {
        let previousCount = avatarViews.count
        let diff = numberOfDisplays - previousCount
 
        if diff >= 0 {
            (0..<diff).forEach { i in
                let avatarView = AvatarView(size: avatarSize)
                
                let offset: CGFloat = CGFloat(previousCount + i) * (avatarSize.intrinsicContentSize.width - Constants.overlapWidth)
                            
                addSubview(avatarView)
                avatarView.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.left.equalToSuperview().offset(offset)
                }
                
                avatarViews.append(avatarView)
            }
        } else {
            avatarViews.suffix(-diff).forEach { $0.removeFromSuperview() }
            avatarViews.removeLast(-diff)
        }
        
        fadeLayer.removeFromSuperlayer()
        if shouldShowFadeLayer, let lastAvatarView = avatarViews.last {
            lastAvatarView.layer.mask = fadeLayer
            setNeedsLayout()
        }
    }
    
    private func update() {
        avatarViews.enumerated().forEach { i, avatarView in
            avatarView.urlConfiguration = urlConfigurations[i]
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        let count = CGFloat(numberOfDisplays)

        guard urlConfigurations.count > 0 else {
            return .zero
        }
        
        let height = avatarSize.intrinsicContentSize.height
        let width = avatarSize.intrinsicContentSize.width * count - (count - 1) * Constants.overlapWidth
        
        return .init(width: width, height: height)
    }
}


