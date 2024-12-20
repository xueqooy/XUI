//
//  ListController+Reorder.swift
//  XUI
//
//  Created by xueqooy on 2023/9/11.
//

import UIKit
import XKit

public extension ListController {
    private enum Associations {
        static let isReorderGestrueEnabled = Association<Bool>()
        static var reorderLongPresssGestureRecognizer = Association<UILongPressGestureRecognizer>()
    }

    var isReorderGestrueEnabled: Bool {
        set {
            guard isReorderGestrueEnabled != newValue else {
                return
            }

            if newValue {
                listView.addGestureRecognizer(reorderLongPresssGestureRecognizer)
            } else {
                listView.removeGestureRecognizer(reorderLongPresssGestureRecognizer)
            }
        }
        get {
            Associations.isReorderGestrueEnabled[self] ?? false
        }
    }

    private var reorderLongPresssGestureRecognizer: UILongPressGestureRecognizer {
        var gestureRecognizer = Associations.reorderLongPresssGestureRecognizer[self]
        if gestureRecognizer == nil {
            gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(Self.handleReorderLongGesture(gesture:)))
            Associations.reorderLongPresssGestureRecognizer[self] = gestureRecognizer
        }
        return gestureRecognizer!
    }

    @objc private func handleReorderLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            let touchLocation = gesture.location(in: listView)
            guard let selectedIndexPath = listView.indexPathForItem(at: touchLocation) else {
                break
            }
            listView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            if let view = gesture.view {
                let position = gesture.location(in: view)
                listView.updateInteractiveMovementTargetPosition(position)
            }
        case .ended:
            listView.endInteractiveMovement()
        default:
            listView.cancelInteractiveMovement()
        }
    }
}
