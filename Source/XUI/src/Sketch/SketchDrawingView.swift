//
//  SketchDrawingView.swift
//  XUI
//
//  Created by xueqooy on 2023/7/26.
//

import UIKit
import XKit

class SketchDrawingView: UIView {
    
    typealias Tool = SketchView.Tool
    
    public var tool: Tool = .brush()
    
    public var willBeginDrawing: (() -> Void)?
    public var didFinishDrawing: ((_ undo: @escaping () -> Void, _ redo: @escaping () -> Void) -> Void)?
    
    /// Display drawn content
    private let baseLayer = SketchLayer()
    /// Display drawing content
    private let nextLayer = SketchLayer()
    /// Current drawing node
    private var nextNode:  SketchLayerNode?
        
    private var previousBoundingSize: CGSize = .zero
    
    public init() {
        super.init(frame: .zero)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {
        layer.addSublayer(baseLayer)
        layer.addSublayer(nextLayer)
    }
    
    public func clear() {
        baseLayer.nodes.removeAll()
        nextLayer.nodes.removeAll()
        nextNode = nil
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        if layer !== self.layer {
            return
        }
        
        let boundingSize = bounds.size
        guard boundingSize.width > 0, boundingSize.height > 0, layer == self.layer, boundingSize != previousBoundingSize else {
            return
        }
        previousBoundingSize = boundingSize
        
        baseLayer.frame = bounds
        nextLayer.frame = bounds

        let updatedBaseNodes = baseLayer.nodes
        let updatedNextNodes = nextLayer.nodes

        updatedBaseNodes.forEach {
            $0.updateBoundingSize(boundingSize)
        }
        updatedNextNodes.forEach {
            $0.updateBoundingSize(boundingSize)
        }

        baseLayer.nodes = updatedBaseNodes
        nextLayer.nodes = updatedNextNodes
    }

    
    // MARK: - Drawing
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, event?.allTouches?.count == 1 else { return }
                
        willBeginDrawing?()
        
        let location = touch.location(in: self)
        
        let nextNode =  SketchLayerNode(tool: tool, startPoint: location, boundingSize: bounds.size)
        self.nextNode = nextNode
        
        switch nextNode.tool {
        case .brush: break
        case .eraser:
            // Copy current nodes to nextLayer and hide baseLayer
            //
            // Clear blend mode cannot affect underlying layer(context)
            // all current nodes need to be copied to the nextLayer
            // So that eraser takes effect when moving
            baseLayer.isHidden = true
            nextLayer.nodes = baseLayer.nodes
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, event?.allTouches?.count == 1 else { return }
        guard let nextNode = nextNode else { return }
        
        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        
        nextNode.move(to: location, previousPoint: previousLocation)
        
        switch nextNode.tool {
        case .brush:
            nextLayer.nodes = [nextNode]
        case .eraser:
            nextLayer.nodes = baseLayer.nodes + [nextNode]
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first, event?.allTouches?.count == 1 else { return }
       
        finishDrawing()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else { return }
        
        finishDrawing()
    }
    
    private func finishDrawing() {
        guard let nextNode = nextNode else { return }
        
        switch nextNode.tool {
        case .brush: break
        case .eraser:
            baseLayer.isHidden = false
        }
        
        baseLayer.nodes.append(nextNode)
        nextLayer.nodes.removeAll()
        
        let undo = { [weak self] in
            guard let self = self else { return }
            if !self.baseLayer.nodes.isEmpty {
                self.baseLayer.nodes.removeLast()
            }
        }
        
        let redo = { [weak self] in
            guard let self = self else { return }
            
            self.baseLayer.nodes.append(nextNode)            
        }
        
        self.nextNode = nil
        
        didFinishDrawing?(undo, redo)
    }
}


