//
//  BadgeLabel.swift
//  XUI
//
//  Created by xueqooy on 2023/2/23.
//

import UIKit

public class BadgeView: UIView {
    
    private struct Constants {
        static let defaultColor: UIColor = Colors.red
        static let textFont = Fonts.body4
        static let dotSize = CGSize(width: 6, height: 6)
        static let numberMinimumSize = CGSize(width: 18, height: 18)
        static let numberPadding = 5.0
        static let defaultOffset = UIOffset(horizontal: 0, vertical: 0)
    }
    
    public var value: String? = nil {
        didSet {
            valueLabel.text = value
    
            invalidateIntrinsicContentSize()
        }
    }
    
    public var color: UIColor {
        set {
            backgroundView.configuration.fillColor = newValue
            updateValueColor()
        }
        get {
            backgroundView.configuration.fillColor ?? .clear
        }
    }
    
    /// Automatically adjust according to `color`, If `color` is dark, `valueColor` is white, and if `color` is light, `valueColor` is black
    public var valueColor: UIColor? = nil {
        didSet {
            updateValueColor()
        }
    }
    
    private var showsValue: Bool {
        if let value = value, !value.isEmpty {
            return true
        }
        return false
    }
    
    private let backgroundView: BackgroundView = {
        var backgroundConfiguration = BackgroundConfiguration()
        backgroundConfiguration.fillColor = Constants.defaultColor
        backgroundConfiguration.cornerStyle = .capsule
        
        return BackgroundView(configuration: backgroundConfiguration)
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        label.textAlignment = .center
        return label
    }()
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    public convenience init(color: UIColor = Colors.lightRed, valueColor: UIColor? = nil, value: String? = nil) {
        self.init(frame: .zero)
        
        defer {
            self.color = color
            self.valueColor = valueColor
            self.value = value
        }
    }
    
    private func initialize() {
        isUserInteractionEnabled = false
        
        updateValueColor()
        
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    public func addToView(_ view: UIView, offset: UIOffset? = nil) {
        if view === self {
            return
        }
        
        let size = sizeThatFits(.max)
        let offset = offset ?? Constants.defaultOffset
        
        view.addSubview(self)
        snp.remakeConstraints { make in
            make.bottom.equalTo(view.snp.top).offset(size.height / 2.0 + offset.vertical)
            make.left.equalTo(view.snp.right).offset(-size.width / 2.0 + offset.horizontal)
        }
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        Self.size(for: value)
    }
    
    public override var intrinsicContentSize: CGSize {
        sizeThatFits(.max)
    }
    
    private func updateValueColor() {
        if let valueColor = valueColor {
            valueLabel.textColor = valueColor
        } else {
            valueLabel.textColor = color.isDark ? .white : .black
        }
    }
}


// MARK: - Size Calculation
public extension BadgeView {
    
    static func size(for text: String?) -> CGSize {
        guard let text else {
            return Constants.dotSize
        }
            
        if !text.isEmpty {
            let textSize = text.preferredSize(for: Constants.textFont)
            return CGSize(width: max(textSize.width + Constants.numberPadding * 2, Constants.numberMinimumSize.width), height: Constants.numberMinimumSize.height)
        } else {
            return Constants.dotSize
        }
    }
}
