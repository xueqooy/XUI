//
//  PageCollectionTitleView.swift
//  LLPUI
//
//  Created by xueqooy on 2024/10/18.
//

import UIKit
import SnapKit

class PageCollectionTitleView: UIView, NestedScrollingHeader {
    
    enum Style {
        case normal
        case navigation
    }
    
    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    /// Vertical offset, only take effect for navigationTitle style 
    var offset: CGFloat = 0 {
        didSet {
            guard offset != oldValue else { return }
            
            topConstrait?.update(offset: offset)
        }
    }
    
    let style: Style
    
    private let titleLabel = UILabel(textColor: Colors.title, font: Fonts.h6)
        .settingContentCompressionResistanceAndHuggingPriority(.required)
    
    private var topConstrait: Constraint?
        
    init(style: Style = .normal, title: String? = nil) {
        self.style = style
        
        super.init(frame: .zero)
        
        clipsToBounds = true
        
        titleLabel.text = title
        
        addSubview(titleLabel)
        switch style {
        case .normal:
            titleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(CGFloat.LLPUI.spacing4)
                make.top.equalToSuperview()
                make.bottom.equalToSuperview().inset(CGFloat.LLPUI.spacing2)
            }
            
        case .navigation:
            titleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                topConstrait = make.top.equalTo(self.snp.bottom).constraint
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        if style == .navigation {
            return .init(width: UIView.noIntrinsicMetric, height: UIView.layoutFittingExpandedSize.height)
        } else {
            return super.intrinsicContentSize
        }
    }
    
}
