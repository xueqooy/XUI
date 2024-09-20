//
//  ContentPresenter.swift
//  LLPUI
//
//  Created by xueqooy on 2023/12/29.
//

import UIKit
import LLPUtils
import Combine

/// Presenting content in a specific style, subclass needs to override `contentView` or` contentController`
open class ContentPresenter {
    
    public enum PresentationStyle {
        case drawer, popover, popup
    }
            
    public let presentationStyle: PresentationStyle
    
    @EquatableState
    public internal(set) var isActive: Bool = false
    
    public weak var presentingViewController: UIViewController?
    /// `sourceView` need to be provided before calling `activate`
    public weak var sourceView: UIView?
    
    /// `sourceRect` is only used for `drawer` presentation style
    public var sourceRect: CGRect?
        
    private lazy var implementor: PresentationImplementor = {
        switch presentationStyle {
        case .drawer:
            return DrawerPresentationImplementor(presenter: self)
            
        case .popover:
            return PopoverPresentationImplementor(presenter: self)
            
        case .popup:
            return PopupPresentationImplementor(presenter: self)
        }
    }()
    
    public init(presentationStyle: PresentationStyle) {
        self.presentationStyle = presentationStyle
    }
    
    public func activate(completion: (() -> Void)? = nil) {
        Logs.warn("sourceView need to be provided before calling activate", tag: "LLPUI", condition: presentationStyle != .popup && sourceView == nil)
        implementor.activate(completion: completion)
    }
    
    public func deactivate(completion: (() -> Void)? = nil) {
        implementor.deactivate(completion: completion)
    }
    
    
    // MARK: - Subclass Overrides
    
    open var contentController: UIViewController? { nil }
    
    open var contentView: UIView? { nil }
    
    open var preferredContentSize: CGSize? { nil }
    
    open var popoverConfiguration: Popover.Configuration { .init() }
    
    open var drawerConfiguration: DrawerController.Configuration { .init() }
    
    open var popupConfiguration: PopupController.Configuration { .init() }
    
    open var finalPresentingViewController: UIViewController? {
        var presentingViewController = presentingViewController ?? sourceView?.findContainingViewController()
        if presentingViewController == nil, let window = sourceView?.window ?? UIApplication.shared.keyWindows.first {
            presentingViewController = window.rootViewController
        }
        return presentingViewController
    }
    
}
