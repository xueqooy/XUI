//
//  Nested.swift
//  Pods
//
//  Created by xueqooy on 2024/11/20.
//

import UIKit
import SnapKit

public class TitledNestedScrollingConfiguration: NestedScrollingConfiguration {
    
    private var navigationTitleView: TitleView?
    
    public init(title: String, isRefreshEnabled: Bool = true, customHeaderView: UIView? = nil) {
        navigationTitleView = if Device.current.isPhone {
            TitleView(style: .navigation, title: title)
        } else {
            nil
        }
        
        let titleView = TitleView(style: .normal(customView: customHeaderView), title: title)
        
        super.init(headerView: titleView, isRefreshEnabled: isRefreshEnabled, stickyHeader: navigationTitleView == nil)
    }
    
    public override func didAdd(to viewController: UIViewController) {
        guard let navigationTitleView, viewController.navigationItem.leftBarButtonItem == nil else { return }
        
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navigationTitleView)
    }
    
    public override func parentContentOffsetDidChange(_ offset: CGFloat) {
        guard let navigationTitleView else { return }
        
        navigationTitleView.offset = -offset
    }
}


private class TitleView: UIView, NestedScrollingHeader {
    
    enum Style {
        case normal(customView: UIView? = nil)
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
            
            let boundingHeight = bounds.height
            let minOffset = -(boundingHeight - (boundingHeight - titleLabel.bounds.height) / 2)
            
            offset = min(max(minOffset, offset), 0)
            
            topConstraitForNavigation?.update(offset: offset)
        }
    }
    
    let style: Style
    
    private let titleLabel = UILabel(textColor: Colors.title, font: Fonts.h6)
        .settingContentCompressionResistanceAndHuggingPriority(.required)
    
    private var topConstraitForNavigation: Constraint?
        
    init(style: Style = .normal(), title: String? = nil) {
        self.style = style
        
        super.init(frame: .zero)
        
        clipsToBounds = true
        
        titleLabel.text = title
        
        addSubview(titleLabel)
        switch style {
        case .normal(let customView):
            titleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(CGFloat.LLPUI.spacing4)
                make.top.equalToSuperview()
                
                if customView == nil {
                    make.bottom.equalToSuperview().inset(CGFloat.LLPUI.spacing2)
                }
            }
            
            if let customView {
                addSubview(customView)
                customView.snp.makeConstraints { make in
                    make.top.equalTo(titleLabel.snp.bottom).offset(CGFloat.LLPUI.spacing2)
                    make.left.right.equalToSuperview().inset(CGFloat.LLPUI.spacing4)
                    make.bottom.equalToSuperview().inset(CGFloat.LLPUI.spacing2)
                }
            }
            
        case .navigation:
            titleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                topConstraitForNavigation = make.top.equalTo(self.snp.bottom).constraint
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        if case .navigation = style {
            return .init(width: UIView.noIntrinsicMetric, height: UIView.layoutFittingExpandedSize.height)
        } else {
            return super.intrinsicContentSize
        }
    }
    
}

