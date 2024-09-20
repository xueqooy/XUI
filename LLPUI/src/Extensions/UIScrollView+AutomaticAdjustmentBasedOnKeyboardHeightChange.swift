//
//  UIScrollView+AutomaticAdjustmentBasedOnKeyboardHeightChange.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/11.
//

import UIKit
import LLPUtils
import Combine

public enum FirstResponderContainerVisibilityPosition {
    /// Make top of container visible
    case top
    /// Make bottom of container visible
    case bottom
}

/// When getting the first responder, it will look up the superview. If a superview view follows the protocol, ensure that the view will not be blocked by the keyboard.
public protocol FirstResponderContainer {
    var visibilityPosition: FirstResponderContainerVisibilityPosition { get }
}


public extension FirstResponderContainer {
    var visibilityPosition: FirstResponderContainerVisibilityPosition {
        .bottom
    }
}


/// Provide a capability that automatically adjusts content insets when keyboard is shown/hidden to make sure scrollable area is always visible.
/// Also provides methods to scroll any subview (or first responder if it's a subview) to visible area.
public extension UIScrollView {
    private struct Associations {
        static let keyboardManager = Association<KeyboardManager>()
        static let cancellable = Association<AnyCancellable>()
        static let originalBottomContentInset = Association<CGFloat>()
        static let latestKeyboardInfo = Association<KeyboardInfo>(wrap: .retain)
        static let makesFirstResponderVisibleWhenKeyboardHeightChange = Association<Bool>()
    }
    
    /// Whether to automatically adjust bottom inset based on docked keyboard height
    var automaticallyAdjustsBottomInsetBasedOnKeyboardHeight: Bool {
        set {
            if newValue && !isEnabled {
                // Enable
                let cancellable = keyboardManager.didReceiveEventPublisher
                    .filter { $0.0 == .willChangeFrame || $0.0 == .didChangeFrame }
                    .sink { [weak self] (_, info) in
                        guard let self = self else {
                            return
                        }
                        
                        self.keyboardWillChangeFrame(info)
                    }
                
                Associations.cancellable[self] = cancellable
                
            } else if !newValue && isEnabled {
                // Disable
                Associations.cancellable[self] = nil
            }
        }
        get {
            isEnabled
        }
    }
    
    private var isEnabled: Bool {
        Associations.cancellable[self] != nil
    }
    
    /// Lazy load
    private var keyboardManager: KeyboardManager {
        var manager = Associations.keyboardManager[self]
        if manager == nil {
            manager = KeyboardManager()
            Associations.keyboardManager[self] = manager
        }
        return manager!
    }
    
    private var originalBottomContentInset: CGFloat? {
        set { Associations.originalBottomContentInset[self] = newValue }
        get { Associations.originalBottomContentInset[self] }
    }
    
    private var latestKeyboardInfo: KeyboardInfo? {
        set { Associations.latestKeyboardInfo[self] = newValue }
        get { Associations.latestKeyboardInfo[self] }
    }
    
    /// Works when set `automaticallyAdjustsBottomInsetBasedOnKeyboardHeight` to `true`
    var makesFirstResponderVisibleWhenKeyboardHeightChange: Bool {
        set { Associations.makesFirstResponderVisibleWhenKeyboardHeightChange[self] = newValue }
        get { Associations.makesFirstResponderVisibleWhenKeyboardHeightChange[self] ?? true }
    }
        
    /// First responder needs to be the descendant view
    func makeFirstResponderVisible(animated: Bool = false) {
        if let firstResponder = keyboardManager.currentResponder as? UIView, firstResponder.isDescendant(of: self) {
            makeSubviewVisible(firstResponder, animated: animated)
        }
    }
    
    func makeSubviewVisible(_ view: UIView, animated: Bool = false) {
        self.layoutIfNeeded()
        let container = self.containerForView(view)
        // Rect of container in self
        let rect = self.convert(container.frame, from: container.superview)
        let contentBounds = self.bounds.inset(by: self.contentInset)
        var updatedContentOffset = self.contentOffset
        
        let visibilityPosition = (container as? FirstResponderContainer)?.visibilityPosition ?? .bottom
        
        switch visibilityPosition {
        case .top:
            // Make top of container visible
            updatedContentOffset.y -= max(0, contentBounds.minY - rect.minY)
            
        case .bottom:
            // Make bottom of container visible
            updatedContentOffset.y += max(0, rect.maxY - contentBounds.maxY)
        }

        if let keyboardInfo = latestKeyboardInfo {
            if animated {
                UIView.animate(keyboardInfo: keyboardInfo) {
                    self.contentOffset = updatedContentOffset
                }
            } else {
                contentOffset = updatedContentOffset
            }
        } else {
            setContentOffset(updatedContentOffset, animated: animated)
        }
    }
    
    private func containerForView(_ view: UIView) -> UIView {
        var container = view
        repeat {
            if container is FirstResponderContainer {
                return container
            }
            container = container.superview!
        } while container != self
        return view
    }
    
    private func keyboardWillChangeFrame(_ info: KeyboardInfo) {
        latestKeyboardInfo = info
        guard let container = superview else {
            return
        }

        // TODO: Should we need this?
//        guard let view = info.targetResponder as? UIView, view.isDescendant(of: self) else {
//            return
//        }
        
        if var keyboardFrame = info.endFrame {
            keyboardFrame = container.convert(keyboardFrame, from: nil)
            if originalBottomContentInset == nil {
                originalBottomContentInset = contentInset.bottom
            }
            
            let bottomInset = max(originalBottomContentInset!, (KeyboardManager.visibleRect(in: self, keyboardRect: info.endFrame)?.height ?? 0) + originalBottomContentInset!)
            if contentInset.bottom != bottomInset {
                contentInset.bottom = bottomInset
                verticalScrollIndicatorInsets.bottom = bottomInset
            }
            
            let willKeyboardShow = info.beginFrame?.minY ?? 0 > info.endFrame?.minY ?? 0
            
            if makesFirstResponderVisibleWhenKeyboardHeightChange && willKeyboardShow {
                makeFirstResponderVisible(animated: true)
            }
        }
    }
}
