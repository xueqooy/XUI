//
//  PopupTopView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/2/28.
//

import UIKit
import SnapKit

class PopupTopView: UIView {
    
    private struct Constants {
        static let componentHeight = 24.0
        static let componentSpacing: CGFloat = .LLPUI.spacing2
        static let margins = UIEdgeInsets(top: .LLPUI.spacing5, left: .LLPUI.spacing5, bottom: 0, right: .LLPUI.spacing5)
        static let marginsWhenTitleShown = UIEdgeInsets(top: .LLPUI.spacing5, left: .LLPUI.spacing5, bottom: .LLPUI.spacing5, right: .LLPUI.spacing5)
    }
    
    private let componentLayoutGuide = ConstraintLayoutGuide()
    
    private lazy var separator = SeparatorView()
    
    private let showsTitle: Bool
    
    init?(title: String?, cancelAction: (() -> Void)?) {
        let showsTitle = !(title ?? "").isEmpty
        let showsCancelButton = cancelAction != nil
        
        if !showsTitle && !showsCancelButton {
            return nil
        }
        
        self.showsTitle = showsTitle
        
        super.init(frame: .zero)
        
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)

        let titleAndCancelButtonView = TitleAndButtonView(title: title, titleLines: 2, buttonConfiguration: showsCancelButton ? .init(image: Icons.cancel) : nil, buttonAction: showsCancelButton ? { _ in cancelAction!() } : nil)
        
        addSubview(titleAndCancelButtonView)
        titleAndCancelButtonView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(CGFloat.LLPUI.spacing5)
            if showsTitle {
                make.centerY.equalToSuperview()
            } else {
                make.bottom.equalToSuperview()
            }
        }
    
        if showsTitle {
            addSubview(separator)
            separator.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: showsTitle ? 64 : 44)
    }
}
