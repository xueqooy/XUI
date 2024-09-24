//
//  DropdownMenu.swift
//  LLPUI
//
//  Created by xueqooy on 2024/5/7.
//

import UIKit
import LLPUtils
import IGListDiffKit
import Combine

public class DropdownMenu {
        
    public class Action: StateObservableObject {
    
        public typealias Handler = (Action) -> Void
        
        public enum State: Equatable {
            case on
            case off
        }
        
        public struct Attributes : OptionSet {
            /// Indicates that the menu should remain presented after firing the element's action rather than dismissing as it normally does.
            public static var keepsMenuPresented: Attributes = .init(rawValue: 1)
            
            public let rawValue: Int8
            
            public init(rawValue: Int8) {
                self.rawValue = rawValue
            }
        }
        
        @EquatableState
        public var title: String
        
        public let identifier: String
        
        @EquatableState
        public var state: State
        
        @EquatableState
        public var attributes: Attributes
        
        let handler: Handler
        
        public init(title: String, identifier: String? = nil, attributes: Attributes = [], state: State, handler: @escaping Handler) {
            self.title = title
            self.identifier = identifier ?? UUID().uuidString
            self.attributes = attributes
            self.state = state
            self.handler = handler
        }
    }
    
    public struct Preference {
        
        public enum Style {
            case plain
            case large
        }
        
        public var style: Style
        
        public var showsArrow: Bool
        
        public var minimumContentWidth: CGFloat
        public var maximumContentWidth: CGFloat
        
        public var maximumContentHeight: CGFloat?
        
        public init(style: Style = .plain, showsArrow: Bool = false, minimumContentWidth: CGFloat = 100, maximumContentWidth: CGFloat = 260, maximumContentHeight: CGFloat? = nil) {
            self.style = style
            self.showsArrow = showsArrow
            self.minimumContentWidth = minimumContentWidth
            self.maximumContentWidth = maximumContentWidth
            self.maximumContentHeight = maximumContentHeight
        }
    }
    
    public var title: String?
     
    public var actions = [Action]() {
        didSet {
            maybeUpdateContent()
        }
    }
    
    public var preference: Preference

    
    @EquatableState
    public var isShowing = false {
        didSet {
            if !isShowing {
                currentContentView = nil
                orientationChangedSubscription = nil
            }
        }
    }
            
    private lazy var popover: Popover = {
        var configuration = Popover.Configuration()
        configuration.preferredDirection = .down
        configuration.delayHidingOnAnchor = true
        configuration.dismissMode = .tapOnOutsidePopover
        
        let popover = Popover(configuration: configuration)
        
        popoverDisplaySubscription = popover.$isShowing.willChange
            .sink { [weak self] in
                guard let self else { return }
                
                self.isShowing = $0
            }
        
        return popover
    }()
    
    private var currentContentView: DropdownMenuContentView?
    
    private var preferredContentSize: CGSize {
        DropdownMenuContentView.calculateContentSize(with: actions, title: title, preference: preference)
    }
    
    private var popoverDisplaySubscription: AnyCancellable?
    
    private var orientationChangedSubscription: AnyCancellable?
    
    public init(title: String? = nil, preference: Preference = .init(), actions: [Action] = []) {
        self.title = title
        self.preference = preference
        self.actions = actions
    }
    
    public func show(from sourceView: UIView, animated: Bool = true) {
        orientationChangedSubscription = nil
        
        // Create content view
        let contentView = DropdownMenuContentView(dropDownMenu: self)
        self.currentContentView = contentView
        
        maybeUpdateContent()
        
        // Update popover configuration
        popover.update { configuration in
            if preference.showsArrow {
                configuration.animationTransition = .zoom
                configuration.arrowSize = CGSize(width: 16, height: 10)
            } else {
                configuration.animationTransition = .push
                configuration.arrowSize = .zero
            }
            
            configuration.maximumContentWidth = preference.maximumContentWidth
            configuration.maximumContentHeight = preference.maximumContentHeight
        
            configuration.contentInsets = preference.style.popoverContentInsets
            
            configuration.background.cornerStyle = .fixed(preference.style.menuBackgroundCornerRadius)
        }
        
        // Show popover
        popover.show(contentView, preferredContentSize: preferredContentSize, from: sourceView, animated: animated)
        
       
        // Deactivate select when device orientation changed
        orientationChangedSubscription = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in
                Device.current.orientation
            }
            .removeDuplicates()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                if self.isShowing {
                    self.hide()
                }
            }
    }
    
    public func hide(animated: Bool = true) {
        popover.hide(animated: animated)
    }
  
    
    private func maybeUpdateContent() {
        Task { @MainActor in
            guard let contentView = self.currentContentView else { return }

            contentView.objects = self.actions
        }
    }
}

extension DropdownMenu.Action : ListDiffable {
    
    public func diffIdentifier() -> NSObjectProtocol {
        identifier as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object else {
            return false
        }
        
        /// Alway reload when object is not the same instance
        return object === self
    }
}


extension DropdownMenu.Preference.Style {
    
    var rowHeight: CGFloat {
        switch self {
        case .plain:
            40
        case .large:
            48
        }
    }
    
    var actionTitleFont: UIFont {
        switch self {
        case .plain:
            Fonts.body2Bold
        case .large:
            Fonts.body1Bold
        }
    }
    
    var menuTitleFont: UIFont {
        switch self {
        case .plain:
            Fonts.body3Bold
        case .large:
            Fonts.body2Bold
        }
    }
    
    var menuBackgroundCornerRadius: CGFloat {
        switch self {
        case .plain:
            15
        case .large:
            .LLPUI.cornerRadius
        }
    }
    
    var actionHighlightCornerRadius: CGFloat {
        switch self {
        case .plain:
            .LLPUI.smallCornerRadius
        case .large:
            15
        }
    }
    
    var popoverContentInsets: UIEdgeInsets {
        switch self {
        case .plain:
            UIEdgeInsets(uniformValue: .LLPUI.spacing3)

        case .large:
            UIEdgeInsets(uniformValue: .LLPUI.spacing4)
        }
    }
    
    var actionTitleHorizontalInset: CGFloat {
        switch self {
        case .plain:
            .LLPUI.spacing2

        case .large:
            .LLPUI.spacing3
        }
    }
}
