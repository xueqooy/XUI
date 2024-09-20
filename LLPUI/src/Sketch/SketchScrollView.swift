//
//  SketchScrollView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/7/26.
//

import UIKit
import Combine

class SketchScrollView: UIScrollView {
    
    private struct Constants {
        static let minimumZoomScale = 1.0
        static let maximumZoomScale = 3.0
        static let zoomInFactorAfterDoubleTap = 2.0
    }
    
    private lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Self.doubleTapAction(_:)))
        tapGesture.numberOfTapsRequired = 2
        return tapGesture
    }()
    
    var canDoubleTapToZoomInZoomOut: Bool = false {
        didSet {
            guard canDoubleTapToZoomInZoomOut != oldValue else {
                return
            }
            
            if canDoubleTapToZoomInZoomOut {
                contentView?.addGestureRecognizer(doubleTapGestureRecognizer)
            } else {
                contentView?.addGestureRecognizer(doubleTapGestureRecognizer)
            }
        }
    }
    
    var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            guard let contentView = contentView else {
                return
            }
            
            addSubview(contentView)
            contentView.frame = bounds
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            zoomScale = minimumZoomScale
            contentOffset =  CGPoint.zero
            
            if canDoubleTapToZoomInZoomOut {
                contentView.addGestureRecognizer(doubleTapGestureRecognizer)
            }
        }
    }
    
    private let layoutPropertyObserver = ViewLayoutPropertyObserver()
    private var layoutPropertySubscription: AnyCancellable?
    
    override var frame: CGRect {
        willSet {
            contentSize = frame.size
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {
        isScrollEnabled = false
        minimumZoomScale = Constants.minimumZoomScale
        maximumZoomScale = Constants.maximumZoomScale
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        decelerationRate = UIScrollView.DecelerationRate.fast
        delegate = self
        
        layoutPropertyObserver.addToView(self)
        layoutPropertySubscription = layoutPropertyObserver.propertyDidChangePublisher
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                
                self.zoomScale = Constants.minimumZoomScale
                self.contentSize = self.frame.size
                self.contentView?.frame = CGRect(origin: .zero, size: self.frame.size)
            }
    }
 
    private func adjustFrameToCenter() {
        guard let contentView = contentView else {
            return
        }
        
        var frameToCenter = contentView.frame
        
        // center horizontally
        if frameToCenter.size.width < bounds.width {
            frameToCenter.origin.x = (bounds.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
        if frameToCenter.size.height < bounds.height {
            frameToCenter.origin.y = (bounds.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        contentView.frame = frameToCenter
    }
    
    @objc private func doubleTapAction(_ gestureRecognizer: UIGestureRecognizer) {
        let zoomInFactor = Constants.zoomInFactorAfterDoubleTap
        // zoom out if it bigger than the scale factor after double-tap scaling. Else, zoom in
        if zoomScale >= minimumZoomScale * zoomInFactor - 0.01 {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            let center = gestureRecognizer.location(in: gestureRecognizer.view)
            let zoomRect = zoomRectForScale(zoomInFactor * minimumZoomScale, center: center)
            zoom(to: zoomRect, animated: true)
        }
    }
    
    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        
        // the zoom rect is in the content contentView's coordinates.
        // at a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
        // as the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.height = frame.size.height / scale
        zoomRect.size.width  = frame.size.width  / scale
        
        // choose an origin so as to get the right center.
        zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
}


extension SketchScrollView: UIScrollViewDelegate {
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustFrameToCenter()
    }
    
}
