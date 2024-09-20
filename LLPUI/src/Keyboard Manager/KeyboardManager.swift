//
//  KeyboardManager.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/10/19.
//

import Foundation
import LLPUtils
import Combine

// MARK: - Keyboard Manager Delegate

public protocol KeyboardManagerDelegate: AnyObject {
    func keyboardManager(_ manager: KeyboardManager, didReceive event: KeyboardManager.Event, info: KeyboardInfo)
}


// MARK: - Keyboard Manager

public class KeyboardManager {
    
    public enum Event {
        case willShow, didShow
        case willChangeFrame, didChangeFrame
        case willHide, didHide
    }
    
    public enum ResponderMode {
        case all
        case specified
    }
        
    public var ignoresApplicationState: Bool = false
    public var responderMode: ResponderMode = .all
        
    public weak var delegate: KeyboardManagerDelegate?
    
    public var didReceiveEventPublisher: AnyPublisher<(Event, KeyboardInfo), Never> {
        didReceiveEventSubject.eraseToAnyPublisher()
    }
    private var didReceiveEventSubject = PassthroughSubject<(Event, KeyboardInfo), Never>()
    
    public var responders: [UIResponder] {
        responderWeakSet.elements
    }
    
    public private(set) weak var currentResponder: UIResponder?
    
    public init() {
        UIResponder.setup_keyboardManager_isFirstResponder()
        
        addKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func addResponder(_ responder: UIResponder) {
        responderWeakSet.insert(responder)
    }

    public func removeResponder(_ responder: UIResponder) {
        responderWeakSet.remove(responder)
    }
    
    // MARK: Private
        
    private lazy var responderWeakSet = WeakSet<UIResponder>()
        
    private func addKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShowNotification(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardDidShowNotification(_:)), name: UIApplication.keyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHideNotification(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardDidHideNotification(_:)), name: UIApplication.keyboardDidHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillChangeFrameNotification(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardDidChangeFrameNotification(_:)), name: UIApplication.keyboardDidChangeFrameNotification, object: nil)
    }
    
    
    private var isAppActive: Bool {
        if ignoresApplicationState {
            return true
        }
        if UIApplication.shared.applicationState == .active {
            return true
        }
        return false
    }
    
    private var shouldReceiveShowNotification: Bool {
        let firstResponder = Self.firstResponderInWindows
        if self.currentResponder != nil {
            // There is a bug. If the webview is clicked and the keyboard drops, the shouldReceiveHideNotification will judge incorrectly. Therefore, if it is nil or WKContentView, the value will remain unchanged.
            if let firstResponder = firstResponder, let wkContentViewClass = NSClassFromString("WKContentView"), firstResponder.isKind(of: wkContentViewClass) {
            } else {
                self.currentResponder = firstResponder
            }
        } else {
            self.currentResponder = firstResponder
        }
        
        if responderMode == .all {
            return true
        } else {
            if let currentResponder = currentResponder {
                return responders.contains(currentResponder)
            } else {
                return false
            }
        }
    }
    
    private var shouldReceiveHideNotification: Bool {
        if responderMode == .all {
            return true
        } else {
            if let currentResponder = currentResponder {
                return responders.contains(currentResponder)
            } else {
                return false
            }
        }
    }
    
    private func sendEvent(_ event: Event, info: KeyboardInfo) {
        delegate?.keyboardManager(self, didReceive: event, info: info)
        didReceiveEventSubject.send((event, info))
    }
    
    // MARK: Event Handling
        
    @objc private func keyboardWillShowNotification(_ notification: Notification) {
        guard isAppActive && Self.isLocalKeyboard(notification) && shouldReceiveShowNotification  else {
            return
        }
        
        let keyboardInfo = KeyboardInfo(notification: notification, targetResponder: currentResponder)
        
        sendEvent(.willShow, info: keyboardInfo)
    }
    
    @objc private func keyboardDidShowNotification(_ notification: Notification) {
        guard isAppActive && Self.isLocalKeyboard(notification) else {
            return
        }
        
        let firstResponder = Self.firstResponderInWindows
        let shouldReceiveDidShowNotification: Bool = responderMode == .all || (firstResponder != nil && firstResponder == currentResponder)
       
        let keyboardInfo = KeyboardInfo(notification: notification, targetResponder: currentResponder)
        
        if shouldReceiveDidShowNotification {
            sendEvent(.didShow, info: keyboardInfo)
        }
    }
    
    @objc private func keyboardWillHideNotification(_ notification: Notification) {
        guard isAppActive && Self.isLocalKeyboard(notification) && shouldReceiveHideNotification else {
            return
        }
                
        let keyboardInfo = KeyboardInfo(notification: notification, targetResponder: currentResponder)
        
        sendEvent(.willHide, info: keyboardInfo)
    }
    
    @objc private func keyboardDidHideNotification(_ notification: Notification) {
        guard isAppActive && Self.isLocalKeyboard(notification) else {
            return
        }
                
        let keyboardInfo = KeyboardInfo(notification: notification, targetResponder: currentResponder)
        
        if shouldReceiveHideNotification {
            sendEvent(.didHide, info: keyboardInfo)
        }
        
        if let currentResponder = currentResponder, !currentResponder.keyboardManager_isFirstResponder {
            // Latest time, set to nil
            self.currentResponder = nil
        }
    }
    
    @objc private func keyboardWillChangeFrameNotification(_ notification: Notification) {
        guard isAppActive && Self.isLocalKeyboard(notification) && (shouldReceiveShowNotification || shouldReceiveHideNotification) else {
            return
        }
                
        let keyboardInfo = KeyboardInfo(notification: notification, targetResponder: currentResponder)
        
        sendEvent(.willChangeFrame, info: keyboardInfo)
    }
    
    @objc private func keyboardDidChangeFrameNotification(_ notification: Notification) {
        guard isAppActive && Self.isLocalKeyboard(notification) && (shouldReceiveShowNotification || shouldReceiveHideNotification) else {
            return
        }
            
        let keyboardInfo = KeyboardInfo(notification: notification, targetResponder: currentResponder)
        
        sendEvent(.didChangeFrame, info: keyboardInfo)
    }
}
