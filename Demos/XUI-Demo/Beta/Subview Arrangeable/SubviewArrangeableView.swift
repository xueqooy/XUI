//
//  SubviewArrangeableView.swift
//  EDUI
//
//  Created by 🌊 薛 on 2022/9/20.
//

import UIKit

open class SubviewArrangeableView: UIView, SubviewArrangeable {
    open private(set) var arrangedSubviews: [UIView]

    /// Whether `addArrangedSubview/removeArrangedSubview/insertArrangedSubview` is executing. When processing arrangedSubviews, the `willRemoveSubview` method will be abnormally triggered, causing the subview to be removed incorrectly. When the above methods are executed, the `willRemoveSubview` method will be ignored
    private var modifyingArrangedSubviews: Bool = false

    public init(frame: CGRect = CGRect.zero, arrangedSubviews: [UIView] = []) {
        // deduplicate
        var keys: [UIView: ()] = [:]
        self.arrangedSubviews = arrangedSubviews.filter { keys.updateValue((), forKey: $0) == nil }

        super.init(frame: frame)

        for arrangedSubview in arrangedSubviews {
            addSubview(arrangedSubview)
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setArrangedSubviews(_ views: [UIView]) {
        modifyingArrangedSubviews = true

        for view in arrangedSubviews {
            if views.contains(view) == false {
                view.removeFromSuperview()
            }
        }

        // deduplicate
        var keys: [UIView: ()] = [:]
        arrangedSubviews = views.filter { keys.updateValue((), forKey: $0) == nil }

        for arrangedSubview in arrangedSubviews {
            addSubview(arrangedSubview)
        }

        setNeedsLayout()

        modifyingArrangedSubviews = false
    }

    open func addArrangedSubview(_ view: UIView) {
        modifyingArrangedSubviews = true

        if let index = arrangedSubviews.firstIndex(of: view) {
            if index != arrangedSubviews.count - 1 {
                arrangedSubviews.remove(at: index)
                arrangedSubviews.append(view)
                setNeedsLayout()
            }
        } else {
            arrangedSubviews.append(view)
            addSubview(view)
            setNeedsLayout()
        }

        modifyingArrangedSubviews = false
    }

    open func removeArrangedSubview(_ view: UIView) {
        modifyingArrangedSubviews = true

        if let index = arrangedSubviews.firstIndex(of: view) {
            arrangedSubviews.remove(at: index)

            if subviews.contains(view) {
                view.removeFromSuperview()
            }
        }

        modifyingArrangedSubviews = false
    }

    open func insertArrangedSubview(_ view: UIView, at index: Int) {
        precondition(index > 0 && index <= arrangedSubviews.count, "Insertion Out Of Bounds")

        modifyingArrangedSubviews = true

        if let previousIndex = arrangedSubviews.firstIndex(of: view) {
            if previousIndex > index {
                arrangedSubviews.remove(at: previousIndex)
                arrangedSubviews.insert(view, at: index)
                setNeedsLayout()
            } else if previousIndex < index {
                arrangedSubviews.insert(view, at: min(index + 1, arrangedSubviews.count))
                arrangedSubviews.remove(at: previousIndex)
                setNeedsLayout()
            }

        } else {
            arrangedSubviews.insert(view, at: index)
            addSubview(view)
            setNeedsLayout()
        }

        modifyingArrangedSubviews = false
    }

    override public func willRemoveSubview(_ subview: UIView) {
        if modifyingArrangedSubviews {
            return
        }

        if let index = arrangedSubviews.firstIndex(of: subview) {
            arrangedSubviews.remove(at: index)
            setNeedsLayout()
        }
    }
}
