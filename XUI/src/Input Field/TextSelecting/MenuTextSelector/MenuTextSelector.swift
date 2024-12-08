//
//  MenuTextSelector.swift
//  XUI
//
//  Created by xueqooy on 2023/12/28.
//

import Foundation
import IGListKit
import IGListSwiftKit
import Combine
import XKit

public struct TextSelectorMenuItem {
    /// Text displayed in the menu
    public let title: String
    /// Actual text
    public let text: String
    
    public init(title: String, text: String) {
        self.title = title
        self.text = text
    }
    
    public init(_ titleOrText: String) {
        self.title = titleOrText
        self.text = titleOrText
    }
}

extension TextSelectorMenuItem: ListIdentifiable {
    public var diffIdentifier: NSObjectProtocol {
        text as NSObjectProtocol
    }
}
                                    

public class MenuTextSelector: TextSelector {
        
    public override var contentView: UIView? {
        let listController = ListController()
        listController.sectionControllerProvider = { [weak self, weak listController] item in
            guard let self, let listController else { return nil }
            
            return MenuItemSectionController { [weak self, weak listController] in
                guard let self, let listController else { return }
                
                defer {
                    if self.currentListController === listController {
                        self.deactivate()
                    }
                }
                
                if self.selectedText != $0.text, let shouldSelectItem, !shouldSelectItem($0) {
                    return
                }
                
                // Selected a text
                self.selectedText = $0.text
            }
        }
        
        // Configure list
        currentListController = listController
        
        maybeUpdateList()
        
        // Invalidate layout if size of list view changes
        listLayoutPropertyObserver.addToView(listController.listView)
        listLayoutPropertySubscription = listLayoutPropertyObserver.propertyDidChangePublisher
            .sink { [weak listController] _ in
                guard let listController else { return }
                
                listController.listView.layout.invalidateLayout()
            }
        
        return listController.listView
    }
    
    public override var preferredContentSize: CGSize? {
        let rowHeight: CGFloat = 36
        let preferredHeight = CGFloat(items.count) * rowHeight
        let maximumContentHeight: CGFloat = 200
        let miniumWidth: CGFloat = 100
        
        return CGSize(width: max(miniumWidth, sourceView?.bounds.width ?? miniumWidth), height: min(preferredHeight, maximumContentHeight))
    }
    
    public override var popoverConfiguration: Popover.Configuration {
        var configuration = Popover.Configuration()
        configuration.preferredDirection = .down
        configuration.dismissMode = .tapOnOutsidePopoverAndAnchor
        configuration.animationTransition = .push
        configuration.arrowSize = .zero
        configuration.contentInsets = UIEdgeInsets(top: .XUI.spacing2, left: 0, bottom: .XUI.spacing2, right: 0)
        return configuration
    }
    
    public override var drawerConfiguration: DrawerController.Configuration {
        .init(presentationDirection: .up, resizingBehavior: .dismiss)
    }
    
    public var items: [TextSelectorMenuItem] {
        didSet {
            maybeUpdateList()
        }
    }
    
    public var shouldSelectItem: ((TextSelectorMenuItem) -> Bool)?
    
    private var currentListController: ListController?
    
    private lazy var listLayoutPropertyObserver = ViewLayoutPropertyObserver(properties: [.frame, .bounds])
    
    private var isActiveSubscription: AnyCancellable?
    private var listLayoutPropertySubscription: AnyCancellable?
    
    public init(_ items: [TextSelectorMenuItem] = [], presentationStyle: PresentationStyle = .popover, presentingViewController: UIViewController? = nil) {
        self.items = items
        
        super.init(presentationStyle: presentationStyle)
        
        self.presentingViewController = presentingViewController
        
        isActiveSubscription = $isActive.didChange
            .sink { [weak self] isActive in
                if !isActive {
                    // Release listController after deactivating
                    self?.currentListController = nil
                }
            }
    }
    
    public convenience init(_ texts: [String], presentationStyle: PresentationStyle = .popover, presentingViewController: UIViewController? = nil) {
        self.init(texts.map { TextSelectorMenuItem($0) }, presentationStyle: presentationStyle, presentingViewController: presentingViewController)
    }
    
    private func maybeUpdateList() {
        Task { @MainActor in
            guard let currentListController else {
                return
            }
                        
            await currentListController.updateObjects(items.diffables(), animated: false)
            
            // Configure selected item
            if let selectedIndex = self.items.firstIndex(where: { $0.text == selectedText }), selectedIndex < currentListController.listView.numberOfSections {
                currentListController.listView.selectItem(at: .init(row: 0, section: selectedIndex), animated: false, scrollPosition: .centeredVertically)
            }
        }
    }
}
