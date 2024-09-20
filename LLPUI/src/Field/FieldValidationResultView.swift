//
//  InputValidationView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/5/8.
//

import UIKit
import SnapKit

class FieldValidationResultView: UIView {
    
    private struct Constants {
        static let componentSpacing: CGFloat = .LLPUI.spacing1
    }
    
    var state: Field.ValidationState = .none {
        didSet {
            guard oldValue != state else {
                return
            }
            
            switch state {
            case .success(let text):
                stackView.isHidden = false
                textLabel.textColor = Colors.green
                textLabel.text = text
                imageView.image = Icons.validationSuccess

            case .error(let text):
                stackView.isHidden = false
                textLabel.textColor = Colors.errorText
                textLabel.text = text
                imageView.image = Icons.validationError
        
            default:
                stackView.isHidden = true
            }
        }
    }
    
    private let imageView = UIImageView()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body3
        label.numberOfLines = 0
        return label
    }()
    
    private let stackView = HStackView(alignment: .top, spacing: Constants.componentSpacing).settingHidden(true)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {
        addSubview(stackView)
        stackView.populate {
            imageView
            textLabel
            UIView()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
