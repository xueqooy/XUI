//
//  PageControlIndicatorContentView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/4/12.
//

import UIKit

class PageControlIndicatorContentView: UIView {

    private struct Constants {
        static let indicatorSpacing: CGFloat = .LLPUI.spacing2
        static let animationDuration = 0.2
    }
    
    let maxVisiblePages: Int
    var numberOfPages: Int = 0 {
        didSet {
            if oldValue == numberOfPages {
                return
            }
            preStates.removeAll()
            visibleIndicatorViews.forEach { $0.removeFromSuperview() }
            
            let visibleViewCount = min(numberOfPages, maxVisiblePages)
            visibleIndicatorViews = (0..<visibleViewCount).map {_ in
                let indicatorView = PageControlIndicatorView(color: color)
                addSubview(indicatorView)
                return indicatorView
            }
            
            invalidateIntrinsicContentSize()
        }
    }
    
    var color: UIColor {
        didSet {
            if oldValue == color {
                return
            }
            
            visibleIndicatorViews.forEach { $0.color = color }
            tempIndicatorView.color = color
        }
    }
    
    private(set) var visibleIndicatorViews = [PageControlIndicatorView]()
    private lazy var tempIndicatorView = PageControlIndicatorView(color: color)
    private var preStates = [PageControl.IndicatorState]()

    init(maxVisiblePages: Int, color: UIColor) {
        self.maxVisiblePages = maxVisiblePages
        self.color = color
        
        super.init(frame: .zero)
        
        isUserInteractionEnabled = false
        
        tempIndicatorView.state = .hidden
        addSubview(tempIndicatorView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateIndicatorStates(_ states: [PageControl.IndicatorState]) {
        let preVisibleStatesAndStartIndex = getVisibleStatesAndStartIndex(for: preStates)
        let visibleStatesAndStartIndex = getVisibleStatesAndStartIndex(for: states)
        
        let animated = preStates.count == states.count
        let animatesTranslation = animated && preVisibleStatesAndStartIndex.1 != visibleStatesAndStartIndex.1 && !preVisibleStatesAndStartIndex.0.isEmpty && !visibleStatesAndStartIndex.0.isEmpty
        
        
        if animatesTranslation {
            if preVisibleStatesAndStartIndex.1 < visibleStatesAndStartIndex.1 { // left translate
                let insertIndicatorView = self.tempIndicatorView
                
                self.tempIndicatorView = self.visibleIndicatorViews.removeFirst()

                self.visibleIndicatorViews.append(insertIndicatorView)
                
                insertIndicatorView.state = .hidden
                insertIndicatorView.sizeToFit()
                insertIndicatorView.center = CGPoint(x: self.bounds.width, y: self.bounds.height * 0.5)
            } else { // right translate
                let insertIndicatorView = self.tempIndicatorView
                
                self.tempIndicatorView = self.visibleIndicatorViews.removeLast()
                
                self.visibleIndicatorViews.insert(insertIndicatorView, at: 0)
                
                insertIndicatorView.state = .hidden
                insertIndicatorView.sizeToFit()
                insertIndicatorView.center = CGPoint(x: 0, y: self.bounds.height * 0.5)
            }
        }
        
        let updates = {
            self.visibleIndicatorViews.enumerated().forEach { (index, indicatorView) in
                indicatorView.state = visibleStatesAndStartIndex.0[index]
            }
            
            self.tempIndicatorView.state = .hidden
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: [.curveEaseOut], animations: updates)
        } else {
            updates()
        }
        
        preStates = states
    }
    
    private func getVisibleStatesAndStartIndex(for states: [PageControl.IndicatorState]) -> ([PageControl.IndicatorState], Int) {
        let visibleStartIndex = states.firstIndex { state in
            state != .hidden
        }
        let visibleEndIndex = states.lastIndex { state in
            state != .hidden
        }
    
        if let visibleStartIndex = visibleStartIndex, let visibleEndIndex = visibleEndIndex {
            return (Array(states[visibleStartIndex...visibleEndIndex]), visibleStartIndex)
        } else {
            return ([], 0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let centerY = bounds.height / 2.0
        var centerX = 0.0

        visibleIndicatorViews.forEach { indicatorView in
            indicatorView.sizeToFit()
            
            centerX += (indicatorView.bounds.width / 2.0)
            indicatorView.center = CGPoint(x: centerX, y: centerY)
            
            centerX += (indicatorView.bounds.width / 2.0 + Constants.indicatorSpacing)
            
        }
        
        tempIndicatorView.sizeToFit()
        tempIndicatorView.center = CGPoint(x: tempIndicatorView.center.x, y: centerY)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var height: CGFloat = 0
        var width: CGFloat = 0
        
        visibleIndicatorViews.forEach {
            let size = $0.sizeThatFits(.zero)
            width += size.width
            height = max(height, size.height)
        }
        
        width += ((CGFloat(visibleIndicatorViews.count) - 1.0) * Constants.indicatorSpacing)
        
        return CGSize(width: width, height: height)
    }
    
    override var intrinsicContentSize: CGSize {
        sizeThatFits(.zero)
    }
}
