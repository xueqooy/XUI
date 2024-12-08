//
//  SketchContentView.swift
//  XUI
//
//  Created by xueqooy on 2023/7/27.
//

import UIKit

class SketchContentView: UIView {
    
    private struct Constants {
        static let imageContentMode: UIView.ContentMode = .scaleAspectFit
    }
    
    public var backgroundImage: UIImage? {
        didSet {
            backgroundImageView.image = backgroundImage
            
            drawingView.clear()
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = Constants.imageContentMode
        return imageView
    }()
    
    private(set) lazy var drawingView = SketchDrawingView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {
        addSubview(backgroundImageView)
        addSubview(drawingView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
            
        
        backgroundImageView.frame = bounds
        
        guard let backgroundImage = backgroundImage else {
            drawingView.frame = bounds
            return
        }
        
        let imageSize = backgroundImage.size
        let drawingFrame = bounds.fit(size: imageSize, mode: Constants.imageContentMode)
        
        drawingView.frame = drawingFrame
    }
    
    public func export() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { ctx in
            self.layer.render(in: ctx.cgContext)
        }
    }
}
