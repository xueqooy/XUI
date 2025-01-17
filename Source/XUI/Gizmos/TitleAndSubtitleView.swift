//
//  TitleAndSubtitleView.swift
//  XUI
//
//  Created by xueqooy on 2023/5/8.
//

import SnapKit
import UIKit

public class TitleAndSubtitleView: UIView {
    private let stackView = VStackView()

    public var title: String {
        didSet {
            titleLabel.text = title
        }
    }

    public var subtitle: String {
        didSet {
            subtitleLabel.text = subtitle
        }
    }

    private let titleLabel = UILabel()

    private let subtitleLabel = UILabel()

    public init(title: String, subtitle: String, spacing: CGFloat = .XUI.spacing2, titleStyleConfiguration: TextStyleConfiguration = .init(textColor: Colors.title, font: Fonts.h6, textAlignment: .center), subtitleStyleConfiguration: TextStyleConfiguration = .init(textColor: Colors.bodyText1, font: Fonts.body2, textAlignment: .center)) {
        self.title = title
        self.subtitle = subtitle

        super.init(frame: .zero)

        stackView.spacing = spacing

        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textStyleConfiguration = titleStyleConfiguration

        subtitleLabel.text = subtitle
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textStyleConfiguration = subtitleStyleConfiguration

        stackView.populate {
            titleLabel
            subtitleLabel
        }

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
