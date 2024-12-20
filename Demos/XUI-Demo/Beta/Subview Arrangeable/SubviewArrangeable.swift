//
//  SubviewArrangeable.swift
//  EDUI
//
//  Created by 🌊 薛 on 2022/9/20.
//

import UIKit

public protocol SubviewArrangeable: UIView {
    var arrangedSubviews: [UIView] { get }

    func setArrangedSubviews(_ views: [UIView])
    func addArrangedSubview(_ view: UIView)
    func removeArrangedSubview(_ view: UIView)
    func insertArrangedSubview(_ view: UIView, at index: Int)
}

extension UIStackView: SubviewArrangeable {
    public func setArrangedSubviews(_ views: [UIView]) {
        removeAllSubviews()

        for subview in views {
            addArrangedSubview(subview)
        }
    }
}
