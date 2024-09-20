//
//  ButtonActivityIndicator.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/18.
//

import UIKit

public protocol ButtonActivityIndicator: UIView {
    var indicatorColor: UIColor? { get set }
    
    func startAnimating()
    func stopAnimating()
}


extension UIActivityIndicatorView: ButtonActivityIndicator {
    public var indicatorColor: UIColor? {
        get {
            color
        }
        set {
            color = newValue
        }
    }
}
