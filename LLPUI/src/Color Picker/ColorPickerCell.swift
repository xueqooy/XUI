//
//  ColorPickerCell.swift
//  LLPUI
//
//  Created by xueqooy on 2024/2/20.
//

import UIKit

class ColorPickerCell: UICollectionViewCell {
    
    var color: UIColor? {
        set {
            colorView.configuration.fillColor = newValue
        }
        get {
            colorView.configuration.fillColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            
            selectedImageView.isHidden = false
            selectedImageView.layer.animateScale(from: isSelected ? 0.01 : 1.0, to: isSelected ? 1.0 : 0.01, duration: 0.1, removeOnCompletion: false) { [weak self] _ in
                guard let self else { return }
                
                self.selectedImageView.isHidden = !self.isSelected
            }
            
            colorView.configuration.strokeWidth = isSelected ? 3 : 0
        }
    }
    
    private let colorView = BackgroundView(configuration: .init(strokeColor: Colors.teal, cornerStyle: .fixed(.LLPUI.smallCornerRadius)))
    
    private let selectedImageView = UIImageView(image: Icons.checkboxOn, contentMode: .scaleAspectFill, clipsToBounds: true).settingHidden(true)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(CGFloat.LLPUI.spacing1)
        }
    
        selectedImageView.layer.cornerRadius = 10
        contentView.addSubview(selectedImageView)
        selectedImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize.square(20))
            make.top.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
