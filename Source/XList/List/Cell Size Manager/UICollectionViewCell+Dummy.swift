//
//  UICollectionViewCell+Dummy.swift
//  XUI
//
//  Created by xueqooy on 2024/5/29.
//

import UIKit
import XKit

private let isDummyAssociation = Association<Bool>()

public extension UICollectionViewCell {
    /// Indicate that this cell is a dummy cell, only for layout calculation.
    var isDummy: Bool {
        isDummyAssociation[self] ?? false
    }

    internal func markAsDummy() {
        isDummyAssociation[self] = true
    }
}

public extension UIView {
    /// Check if this view is a descendant of a dummy cell.
    var isDescendantOfDummyCell: Bool {
        if let self = self as? UICollectionViewCell, self.isDummy {
            return true
        }

        if let cell = findSuperview(ofType: UICollectionViewCell.self), cell.isDummy {
            return true
        }
        return false
    }
}
