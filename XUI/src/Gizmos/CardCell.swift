//
//  CardCell.swift
//  XUI
//
//  Created by xueqooy on 2024/10/31.
//

import UIKit

open class CardCell: UICollectionViewCell {
        
    public var isScalePressGestrueEnabled: Bool {
        set {
            scalePressGestureRecognizer.isEnabled = newValue
        }
        get {
            scalePressGestureRecognizer.isEnabled
        }
    }
    
    private lazy var scalePressGestureRecognizer = ProgressivePressGestureRecognizer(maxPressDuration: 0.1, resetDuration: 0.1) { [weak self] progress in
        guard let self else { return }
        
        if progress == 0 {
            self.layer.sublayerTransform = CATransform3DIdentity
            
        } else {
            let finalScale = 0.98
            let scale = (1.0 - progress) + finalScale * progress
            
            self.layer.sublayerTransform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView = BackgroundView(configuration: .overlay())

       
        scalePressGestureRecognizer.priority = .background
        
        addGestureRecognizer(scalePressGestureRecognizer)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
