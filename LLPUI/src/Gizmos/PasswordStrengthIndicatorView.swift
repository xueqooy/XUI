//
//  PasswordStrengthIndicatorView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/20.
//

import UIKit
import SnapKit

public class PasswordStrengthIndicatorView: UIView {
    
    private struct Constants {
        static let lineSpacing: CGFloat = .LLPUI.spacing1
        static let lineHeight: CGFloat = 3
        static let intrinsicHeight: CGFloat = 9
        static let textReservedSpacing: CGFloat = 54.0
        static let labelToLineSpacing: CGFloat = .LLPUI.spacing1
    }
    
    public enum Level: Int, CaseIterable {
        case weak, moderate, strong
        
        var color: UIColor {
            switch self {
            case .weak:
                return Colors.errorText
            case .moderate:
                return Colors.yellow
            case .strong:
                return Colors.validText
            }
        }
        
        var text: String {
            switch self {
            case .weak:
                return Strings.PasswordStrength.weak
            case .moderate:
                return Strings.PasswordStrength.moderate
            case .strong:
                return Strings.PasswordStrength.strong
            }
        }
    }
    
    public var level: Level {
        didSet {
            if oldValue == level {
                return
            }
        
            update()
        }
    }

    private let lineContainerView = HStackView(distribution: .fillProportionally, spacing: Constants.lineSpacing)
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = Fonts.caption
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    public init(level: Level) {
        self.level = level
        
        super.init(frame: .zero)
        
        addSubview(lineContainerView)
        lineContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-Constants.textReservedSpacing)
            make.centerY.equalToSuperview()
        }
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.leading.greaterThanOrEqualTo(lineContainerView.snp.trailing).offset(Constants.labelToLineSpacing)
        }
        
        for _ in 0..<Level.allCases.count {
            lineContainerView.addArrangedSubview(createLineView())
        }
        
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createLineView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = Constants.lineHeight * 0.5
        view.heightAnchor.constraint(equalToConstant: Constants.lineHeight).isActive = true
        return view
    }
    
    private func update() {
        textLabel.text = level.text
        
        for (levelRawVaue, view) in lineContainerView.subviews.enumerated() {
            if level.rawValue >= levelRawVaue {
                view.backgroundColor = Level(rawValue: levelRawVaue)?.color
            } else {
                view.backgroundColor = Colors.line
            }
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Constants.intrinsicHeight)
    }
}
