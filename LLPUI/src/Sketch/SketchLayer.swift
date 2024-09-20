//
//  SketchLayer.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/7.
//

import UIKit

class SketchLayer: CALayer {
    var nodes = [SketchLayerNode]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init() {
        super.init()
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init()
        
        initialize()
    }
    
    private func initialize() {
        contentsScale = UIScreen.main.scale
    }
    
    override func draw(in ctx: CGContext) {
        for node in nodes {
            node.draw(in: ctx)
        }
    }
    
    override func action(forKey event: String) -> CAAction? {
        // remove all default animations.
        return nil
    }
}
