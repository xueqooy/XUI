//
//  PopupTopView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/2/28.
//

import UIKit
import SnapKit

class PopupTopView: UIView {
    
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

        let titleAndCancelButtonView = TitleAndButtonView(
            title: title,
            titleLines: 2,
            titleStyleConfiguration: .init(textColor: .white, font: Fonts.body2Bold, textAlignment: .center),
            buttonConfiguration: showsCancelButton ? .init(image: Icons.xmarkSmall, imageSize: .square(16), foregroundColor: .white) : nil,
            buttonAction: showsCancelButton ? { _ in cancelAction!() } : nil
        )
        
        addSubview(titleAndCancelButtonView)
        titleAndCancelButtonView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(CGFloat.LLPUI.spacing5)
            make.centerY.equalToSuperview()
        }
    
        if showsTitle {
            addSubview(separator)
            separator.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        
        backgroundColor = Colors.teal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: showsTitle ? 64 : 50)
    }
}
