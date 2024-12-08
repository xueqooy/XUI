//
//  HUD.swift
//  CombineCocoa
//
//  Created by xueqooy on 2024/3/13.
//

import UIKit
import XKit

@MainActor public class HUD {

    public enum ContentType {
        case activity(_ text: String? = Strings.loading)
        case text(_ text: String)
        
        var text: String? {
            switch self {
            case .activity(let text):
                return text
            case .text(let text):
                return text
            }
        }
    }
    
    public struct Action {
        public let title: String
        public let handler: () -> Void
        
        public init(title: String, handler: @escaping () -> Void) {
            self.title = title
            self.handler = handler
        }
    }
    
    /// Grace period (0.5) is the time (in seconds) that the invoked method may be run without
    /// showing the HUD. If the task finishes before the grace time runs out, the HUD will
    /// not be shown at all.
    /// This may be used to prevent HUD display for very short tasks.
    private static let gracePeriod: TimeInterval = 0.4
    
    private weak var currentHUDContainerView: HUDContainerView?
    
    private var hideTimer: XKit.Timer?
    private var showTimer: XKit.Timer?

        
    public init() {
        Self.huds.append(self)
    }
    
    deinit {
        guard let currentHUDContainerView else {
            return
        }
                
        Task { @MainActor in
            Self.removeView(currentHUDContainerView)
        }
    }
    
    public func show(_ contentType: ContentType, in view: UIView? = nil, hideAfter delay: TimeInterval = 0, interactionEnabled: Bool = false, action: Action? = nil) {
        
        // Invalid timer
        invalidateTimers()
        
        if delay > 0 || delay == .XUI.autoHideDelay || Self.gracePeriod <= 0 {
            // If specify the hide delay, show immediately
            _show(contentType, in: view, hideAfter: delay, interactionEnabled: interactionEnabled, action: action)
            
        } else {            
            showTimer = XKit.Timer(interval: Self.gracePeriod) { [weak self] in
                guard let self else { return }
                
                _show(contentType, in: view, hideAfter: delay, interactionEnabled: interactionEnabled, action: action)
            }
            showTimer?.start()
        }
    }
    
    public func hide() {
        invalidateTimers()
        
        guard let currentHUDContainerView else { return }
        
        self.currentHUDContainerView = nil
        
        Self.removeView(currentHUDContainerView)
    }
    
    private func _show(_ contentType: ContentType, in view: UIView? = nil, hideAfter delay: TimeInterval = 0, interactionEnabled: Bool = false, action: Action? = nil) {
        guard let view = view ?? UIApplication.shared.keyWindows.first else {
            return
        }
        
        
        // Set up container
        let contentView = dequeueReusableContentView(for: contentType)
        let containerView = currentHUDContainerView ?? HUDContainerView()

        containerView.contentView = contentView
        
        if let action {
            containerView.actionTitle = action.title
            containerView.actionHandler = { [weak self] in
                guard let self else { return }
                
                self.hide()
                
                action.handler()
            }
            
        } else {
            containerView.actionTitle = nil
            containerView.actionHandler = nil
        }

        
        // Add to view
        if containerView.superview !== view {
            view.addSubview(containerView)
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
              
        if containerView.isInteractionEnabled != interactionEnabled || containerView.alpha != 1 {
            let shouldAnimateInteractionChange = currentHUDContainerView?.superview != nil
            if !shouldAnimateInteractionChange {
                containerView.isInteractionEnabled = interactionEnabled
            }
            
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut]) {
                if shouldAnimateInteractionChange {
                    containerView.isInteractionEnabled = interactionEnabled
                }
                containerView.alpha = 1.0
            }
        }
        
        
        // Set up timer
        let actualDelay = delay == .XUI.autoHideDelay ? TimeInterval.smartDelay(for: contentType.text) : delay

        if actualDelay > 0 {
            hideTimer = XKit.Timer(interval: actualDelay) {
                HUD.hide()
            }
            hideTimer?.start()
        }
        
        currentHUDContainerView = containerView
    }
    
    private func invalidateTimers() {
        hideTimer?.stop()
        hideTimer = nil
        
        showTimer?.stop()
        showTimer = nil
    }
    
    private func dequeueReusableContentView(for type: ContentType) -> UIView {
        switch type {
        case .activity(let text):
            let contentView = (currentHUDContainerView?.contentView as? HUDActivityView) ?? HUDActivityView()
            contentView.text = text
            return contentView
            
        case .text(let text):
            let contentView = (currentHUDContainerView?.contentView as? HUDTextView) ?? HUDTextView()
            contentView.text = text
            return contentView
        }
    }
    
    private static func removeView(_ view: UIView) {
        guard view.superview != nil else { return }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .curveEaseIn]) {
            view.alpha = 0.0
            
        } completion: { _ in
            view.removeFromSuperview()
        }
    }
}

extension HUD {
    
    private static let shared: HUD = .init()
    
    public static var huds = WeakArray<HUD>()
    
    public static func show(_ contentType: ContentType, hideAfter delay: TimeInterval = 0, interactionEnabled: Bool = false, action: Action? = nil) {
        shared.show(contentType, hideAfter: delay, interactionEnabled: interactionEnabled, action: action)
    }
    
    public static func hide() {
        shared.hide()
    }
    
    public static func hideAllHUDs() {
        huds.elements.forEach {
            $0.hide()
        }
    }
}

