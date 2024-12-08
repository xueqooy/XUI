//
//  CodeItemView.swift
//  XUI
//
//  Created by xueqooy on 2023/3/7.
//

import UIKit
import SnapKit

class CodeItemView: UIView {
    
    enum State: Equatable {
        
        enum ValidationResult {
            case none
            case error
            case success
        }
        
        case normal(ValidationResult), filled(ValidationResult), focused(ValidationResult), disabled(ValidationResult)
        
        var backgroundConfiguration: BackgroundConfiguration {
            var configuration = BackgroundConfiguration()
            configuration.cornerStyle = .fixed(.XUI.smallCornerRadius)
            configuration.stroke.width = 1
            
            switch self {
            case .normal(let result):
                configuration.stroke.color = switch result {
                case .none:
                    Colors.line2
                    
                case .error:
                    Colors.red
                    
                case .success:
                    Colors.green
                }
                
            case .filled(let result):
                configuration.stroke.color = switch result {
                case .none:
                    Colors.teal
                    
                case .error:
                    Colors.red
                    
                case .success:
                    Colors.green
                }
                
                configuration.fillColor = switch result {
                case .none:
                    Colors.teal.withAlphaComponent(0.05)
                    
                case .error:
                    Colors.lightRed.withAlphaComponent(0.05)
                    
                case .success:
                    Colors.green.withAlphaComponent(0.05)
                }
                
            case .focused(let result):
                configuration.stroke.color = switch result {
                case .none:
                    Colors.teal
                    
                case .error:
                    Colors.red
                    
                case .success:
                    Colors.green
                }
            case .disabled(let result):
                configuration.stroke.color = switch result {
                case .none:
                    Colors.line2
                    
                case .error:
                    Colors.red
                    
                case .success:
                    Colors.green
                }
                configuration.fillColor = Colors.background1
            }
            return configuration
        }
    }
    
    var state: State = .normal(.none) {
        didSet {
            if oldValue == state {
                return
            }
            
            stateDidChange()
        }
    }
    
    var character: Character? {
        didSet {
            if let character = character {
                characterLabel.text = "\(character)"
            } else {
                characterLabel.text = nil
            }
        }
    }
    
    private lazy var gleamAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.timingFunction = .init(name: .easeIn)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 0.55
        return animation
    }()
    
    private lazy var backgroundView = BackgroundView(configuration: state.backgroundConfiguration)
    
    private let characterLabel = UILabel(textColor: Colors.title, font: Fonts.h6, textAlignment: .center)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(characterLabel)
        characterLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func stateDidChange() {
        backgroundView.configuration = state.backgroundConfiguration
        
        if case .focused = state {
            backgroundView.layer.add(gleamAnimation, forKey: "gleam")
        } else {
            backgroundView.layer.removeAnimation(forKey: "gleam")
        }
    }

}
