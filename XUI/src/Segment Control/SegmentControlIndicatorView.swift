//
//  SegmentControlIndicatorView.swift
//  XUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit

class SegmentControlIndicatorView: UIView {
    
    enum Position {
        case left, center, right
    }
    
    var position: Position = .left {
        didSet {
            if oldValue == position {
                return
            }
            
            sliderView.layer.maskedCorners = style.sliderMaskedCorner(for: position)
        }
    }
    
    let style: SegmentControl.Style
    
    lazy var sliderView: UIView = {
        let view = UIView()
        view.backgroundColor = style.sliderColor
        return view
    }()
    
    init(style: SegmentControl.Style) {
        self.style = style
        super.init(frame: .zero)
        
        addSubview(sliderView)
        sliderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(style.sliderThickness)
            
            switch style {
            case .page:
                make.bottom.equalToSuperview()
            case .tab, .toggle:
                make.centerY.equalToSuperview()
            }
        }
        
        switch style.sliderCornerStyle {
        case let .fixed(radius):
            sliderView.layer.cornerRadius = radius
        case .capsule:
            sliderView.layer.cornerRadius = style.sliderThickness / 2
        }
        
        sliderView.layer.maskedCorners = style.sliderMaskedCorner(for: position)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
