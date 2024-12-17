//
//  TitleAndButtonView.swift
//  XUI
//
//  Created by xueqooy on 2024/6/12.
//

import UIKit


public class TitleAndButtonView: UIView {
    
    private lazy var leftPlaceholderView = UIView()
    
    private lazy var titleLabel =  UILabel()
        .settingContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        .settingContentCompressionResistancePriority(.required, for: .vertical)
    
    private lazy var button: Button = {
        let button = Button()
        button.settingContentCompressionResistanceAndHuggingPriority(.required)
        
        return button
    }()
            
    public init(title: String?, titleLines: Int = 2, titleStyleConfiguration: TextStyleConfiguration = .init(textColor: Colors.title, font: Fonts.body1Bold, textAlignment: .center), titleToButtonSpacing: CGFloat = .XUI.spacing3, buttonConfiguration: ButtonConfiguration?, buttonAction: ((UIView) -> Void)? = nil) {
        super.init(frame: .zero)
        
        let shouldShowTitle = !(title ?? "").isEmpty
        let shouldShowButton = buttonConfiguration != nil
        
        if shouldShowTitle {
            titleLabel.text = title
            titleLabel.numberOfLines = titleLines
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.9
            titleLabel.textStyleConfiguration = titleStyleConfiguration
        }
        
        if shouldShowButton {
            button.configuration = buttonConfiguration!
            button.touchUpInsideAction = {
                buttonAction?($0)
            }
        }
        
        let stackView = HStackView(spacing: titleToButtonSpacing) {
            if shouldShowTitle && shouldShowButton {
                leftPlaceholderView
            }
            
            if shouldShowTitle {
                titleLabel
            } else {
                HSpacerView.flexible()
            }
            
            if shouldShowButton {
                if shouldShowTitle {
                    HStackView(alignment: .center) {
                        button
                    }
                } else {
                    button
                }
            }
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if shouldShowTitle && shouldShowButton {
            leftPlaceholderView.widthAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
