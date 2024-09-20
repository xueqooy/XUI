//
//  RangeSliderThumbLayer.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/23.
//

import Foundation

class RangeSliderThumbLayer: RangeSliderLayer {
        
    var isHighlighted: Bool = false {
        didSet {
            guard isHighlighted != oldValue else {
                return
            }
            
            if isHighlighted {
                animateScale(from: 1.0, to: 1.3, duration: 0.15, timingFunction: .easeIn, removeOnCompletion: false)
                
            } else {
                animateScale(from: 1.3, to: 1.0, duration: 0.15, timingFunction: .easeOut, removeOnCompletion: false)
            }
        }
    }
    
    override func draw(in ctx: CGContext) {
        
        let cornerRadius = bounds.height / 2
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        
        ctx.setFillColor(Colors.vibrantTeal.cgColor)
        ctx.addPath(path)
        ctx.fillPath()
    }
}
