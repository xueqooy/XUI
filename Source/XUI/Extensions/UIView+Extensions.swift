//
//  UIView+Extensions.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/9/14.
//

import Combine
import SnapKit
import UIKit

public extension UIView {
    var layoutDirectionIsRTL: Bool {
        effectiveUserInterfaceLayoutDirection == .rightToLeft
    }

    func flipSubviewsForRTL() {
        if effectiveUserInterfaceLayoutDirection == .rightToLeft {
            subviews.forEach { $0.flipForRTL() }
        }
    }

    func flipForRTL() {
        frame = superview?.flipRectForRTL(frame) ?? frame
    }

    func flipRectForRTL(_ rect: CGRect) -> CGRect {
        var newRect = rect
        if effectiveUserInterfaceLayoutDirection == .rightToLeft {
            let contentWidth = (self as? UIScrollView)?.contentSize.width ?? bounds.width
            newRect.origin.x = contentWidth - rect.origin.x - rect.width
        }
        return newRect
    }

    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }

    func findSuperview<T>(ofType _: T.Type) -> T? {
        guard let superview = superview else {
            return nil
        }

        if let superview = superview as? T {
            return superview
        }

        return superview.findSuperview(ofType: T.self)
    }

    func findSubviews<T>(ofType _: T.Type) -> [T] {
        var views = [T]()
        for subview in subviews {
            if let view = subview as? T {
                views.append(view)
            } else if !subview.subviews.isEmpty {
                views.append(contentsOf: subview.findSubviews(ofType: T.self))
            }
        }
        return views
    }

    func findContainingViewController() -> UIViewController? {
        if let nextResponder = next as? UIViewController {
            return nextResponder
        }

        if let nextResponder = next as? UIView {
            return nextResponder.findContainingViewController()
        }

        return nil
    }

    func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }

        for subview in subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }

        return nil
    }
}

// MARK: - Constraints

public extension UIView {
    func addSubview(_ subview: UIView, layoutClosure: (_ make: ConstraintMaker) -> Void) {
        addSubview(subview)
        subview.snp.makeConstraints(layoutClosure)
    }

    /// Search constraints until we find one for the given view
    /// and attribute. This will enumerate ancestors since constraints are
    /// always added to the common ancestor.
    ///
    /// - Parameter attribute: the attribute to find.
    /// - Parameter at: the view to find.
    /// - Returns: matching constraint.
    func findConstraint(attribute: NSLayoutConstraint.Attribute, for view: UIView) -> NSLayoutConstraint? {
        let constraint = constraints.first {
            ($0.firstAttribute == attribute && $0.firstItem as? UIView == view) ||
                ($0.secondAttribute == attribute && $0.secondItem as? UIView == view)
        }
        return constraint ?? superview?.findConstraint(attribute: attribute, for: view)
    }

    func fitIntoSuperview(usingConstraints: Bool = false, usingLeadingTrailing: Bool = true, margins: UIEdgeInsets = .zero, autoWidth: Bool = false, autoHeight: Bool = false) {
        guard let superview = superview else {
            return
        }
        if usingConstraints {
            translatesAutoresizingMaskIntoConstraints = false
            if usingLeadingTrailing {
                leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: margins.left).isActive = true
            } else {
                leftAnchor.constraint(equalTo: superview.leftAnchor, constant: margins.left).isActive = true
            }
            if autoWidth {
                if usingLeadingTrailing {
                    trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -margins.right).isActive = true
                } else {
                    rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -margins.right).isActive = true
                }
            } else {
                widthAnchor.constraint(equalTo: superview.widthAnchor, constant: -(margins.left + margins.right)).isActive = true
            }
            topAnchor.constraint(equalTo: superview.topAnchor, constant: margins.top).isActive = true
            if autoHeight {
                bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -margins.bottom).isActive = true
            } else {
                heightAnchor.constraint(equalTo: superview.heightAnchor, constant: -(margins.top + margins.bottom)).isActive = true
            }
        } else {
            translatesAutoresizingMaskIntoConstraints = true
            frame = superview.bounds.inset(by: margins)
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }

    func fitIntoSuperview() {
        fitIntoSuperview(usingConstraints: false, usingLeadingTrailing: true, margins: .zero, autoWidth: false, autoHeight: false)
    }
}

// MARK: - Setting

public extension UIView {
    @discardableResult
    func settingContentCompressionResistancePriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis? = nil) -> Self {
        if let axis = axis {
            setContentCompressionResistancePriority(priority, for: axis)
        } else {
            setContentCompressionResistancePriority(priority, for: .horizontal)
            setContentCompressionResistancePriority(priority, for: .vertical)
        }

        return self
    }

    @discardableResult
    func settingContentHuggingPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis? = nil) -> Self {
        if let axis = axis {
            setContentHuggingPriority(priority, for: axis)
        } else {
            setContentHuggingPriority(priority, for: .horizontal)
            setContentHuggingPriority(priority, for: .vertical)
        }

        return self
    }

    @discardableResult
    func settingContentCompressionResistanceAndHuggingPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis? = nil) -> Self {
        settingContentCompressionResistancePriority(priority, for: axis)
            .settingContentHuggingPriority(priority, for: axis)
    }

    @discardableResult
    func settingHidden(_ hidden: Bool) -> Self {
        isHidden = hidden
        return self
    }

    @discardableResult
    func settingWidthConstraint(_ width: CGFloat) -> Self {
        constraints
            .filter { $0.firstItem === self && $0.firstAttribute == .width }
            .do { self.removeConstraints($0) }

        widthAnchor.constraint(equalToConstant: width).isActive = true

        return self
    }

    @discardableResult
    func settingHeightConstraint(_ height: CGFloat) -> Self {
        constraints
            .filter { $0.firstItem === self && $0.firstAttribute == .height }
            .do { self.removeConstraints($0) }

        heightAnchor.constraint(equalToConstant: height).isActive = true

        return self
    }

    @discardableResult
    func settingSizeConstraint(_ size: CGSize) -> Self {
        settingWidthConstraint(size.width)
            .settingHeightConstraint(size.height)
    }

    @discardableResult
    func settingCustomSpacingAfter(_ spacing: CGFloat) -> Self {
        customSpacingAfter = spacing
        return self
    }
}

public extension UIView.AnimationOptions {
    static let curveIn = UIView.AnimationOptions(rawValue: 8 << 16)
    static let curveOut = UIView.AnimationOptions(rawValue: 7 << 16)
}
