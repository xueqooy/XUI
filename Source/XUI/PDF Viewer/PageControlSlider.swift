//
//  PageControlSlider.swift
//  XUI
//
//  Created by xueqooy on 2024/12/26.
//

import UIKit
import PDFKit

class PDFControlSlider: UISlider {
    enum `Type` {
        case page
        case scaleFactor
    }
    
    private let type: `Type`
    
    init(type: `Type`) {
        self.type = type
        
        super.init(frame: .zero)
        
        thumbTintColor = Colors.mediumTeal
        minimumTrackTintColor = type == .page ? Colors.mediumTeal : Colors.line1
        maximumTrackTintColor = Colors.line1
        setThumbImage(Icons.sliderThumbSmall?.withTintColor(Colors.mediumTeal), for: .normal)
        setThumbImage(Icons.sliderThumb?.withTintColor(Colors.mediumTeal), for: .highlighted)
        
        if type == .scaleFactor {
            tintColor = .white
            minimumValueImage = UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium))
            maximumValueImage = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium))
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = 2
        rect.origin.y = (bounds.height - rect.height) / 2
        
        if type == .scaleFactor {
            rect = rect.insetBy(dx: -12, dy: 0)
        }
        return rect
    }
    
    override func minimumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.minimumValueImageRect(forBounds: bounds)
        
        if type == .scaleFactor {
            rect.origin.y = (bounds.height - rect.height) / 2
        }
        return rect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: type == .page ? UIView.noIntrinsicMetric : 80, height: 30)
    }
}
