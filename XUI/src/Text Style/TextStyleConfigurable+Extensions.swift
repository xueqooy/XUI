//
//  TextStyleConfiguration+Extensions.swift
//  XKit
//
//  Created by xueqooy on 2023/3/8.
//

import UIKit

extension UILabel: TextStyleConfigurable {
    
    public var textStyleConfiguration: TextStyleConfiguration {
        set {
            textColor = newValue.textColor
            font = newValue.font
            textAlignment = newValue.textAlignment
        }
        get {
            var configuration = TextStyleConfiguration()
            configuration.textColor = textColor
            configuration.font = font
            configuration.textAlignment = textAlignment
            return configuration
        }
    }
}


extension UITextField: TextStyleConfigurable {
    
    public var textStyleConfiguration: TextStyleConfiguration {
        set {
            textColor = newValue.textColor
            font = newValue.font
            textAlignment = newValue.textAlignment
        }
        get {
            var configuration = TextStyleConfiguration()
            configuration.textColor = textColor
            configuration.font = font
            configuration.textAlignment = textAlignment
            return configuration
        }
    }
}


extension UITextView: TextStyleConfigurable {
    public var textStyleConfiguration: TextStyleConfiguration {
        set {
            textColor = newValue.textColor
            font = newValue.font
            textAlignment = newValue.textAlignment
        }
        get {
            var configuration = TextStyleConfiguration()
            configuration.textColor = textColor
            configuration.font = font
            configuration.textAlignment = textAlignment
            return configuration
        }
    }
}

extension InputField: TextStyleConfigurable {
    
    public var textStyleConfiguration: TextStyleConfiguration {
        set {
            textInput.textStyleConfiguration = newValue
        }
        get {
            textInput.textStyleConfiguration
        }
    }
}


extension OptionControl: TextStyleConfigurable {
    public var textStyleConfiguration: TextStyleConfiguration {
        set {
            titleLabel.textStyleConfiguration = newValue
        }
        get {
            titleLabel.textStyleConfiguration
        }
    }
}
