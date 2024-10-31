//
//  CardCell.swift
//  LLPUI
//
//  Created by xueqooy on 2024/10/31.
//

import UIKit

open class CardCell: UICollectionViewCell {
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView = BackgroundView(configuration: .overlay())
        
        let progressiveGestureRecognizer = ProgressivePressGestureRecognizer(maxPressDuration: 0.1, resetDuration: 0.1) { [weak self] progress in
            guard let self else { return }
            
            if progress == 0 {
                self.layer.sublayerTransform = CATransform3DIdentity
                
            } else {
                let finalScale = 0.98
                let scale = (1.0 - progress) + finalScale * progress
                
                self.layer.sublayerTransform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0)
            }
        }
               
        addGestureRecognizer(progressiveGestureRecognizer)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
