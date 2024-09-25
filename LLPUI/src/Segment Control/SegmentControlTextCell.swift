//
//  SegmentControlTextCell.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit

class SegmentControlTextCell: UICollectionViewCell {
        
    private static let textToBadgeSpacing: CGFloat = .LLPUI.spacing1
    
    private let contentStackView = HStackView(alignment: .center, spacing: textToBadgeSpacing)
    
    private let textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textAlignment = .center
        return textLabel
    }()
    
    private let dotBadgeView = BadgeView()
    private let textBadgeView = BadgeView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
        
    private func initialize() {
        contentStackView.addArrangedSubview(textLabel)
        contentStackView.addArrangedSubview(textBadgeView)
        
        dotBadgeView.addToView(textLabel, offset: UIOffset(horizontal: 3, vertical: 0))
        
        dotBadgeView.isHidden = true
        textBadgeView.isHidden = true
        
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func setup(item: SegmentControl.Item, style: SegmentControl.Style, isSelected: Bool) {
        textLabel.text = item.text
        textLabel.font = style.textFont(forSelected: isSelected)
        textLabel.textColor = style.textColor(forSelected: isSelected)
        
        if item.displaysBadge {
            if item.displaysDotBadge {
                dotBadgeView.isHidden = false
                textBadgeView.isHidden = true
            } else {
                textBadgeView.isHidden = false
                dotBadgeView.isHidden = true
                textBadgeView.value = item.badgeValue
            }
            
        } else {
            dotBadgeView.isHidden = true
            textBadgeView.isHidden = true
        }
    }
}


// MARK: - Size Calculation
extension SegmentControlTextCell {
    
    static func size(forItem item: SegmentControl.Item, style: SegmentControl.Style, itemFixedWidth: CGFloat?) -> CGSize {
        var textSize = item.text.preferredSize(for: style.textFont(forSelected: true))
        
        if item.displaysBadge && !item.displaysDotBadge {
            // Display text badge, append badge width
            textSize.width += textToBadgeSpacing
            textSize.width += BadgeView.size(for: item.badgeValue).width
        }
        
        let textInsets = style.textInsets
        let itemWidth = itemFixedWidth ?? textSize.width + textInsets.left + textInsets.right
        let itemHeight = textSize.height + textInsets.top + textInsets.bottom
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
