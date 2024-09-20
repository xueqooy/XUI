//
//  WheelTextSelector.swift
//  LLPUI
//
//  Created by xueqooy on 2024/4/29.
//

import UIKit

public class WheelTextSelector: TextSelector {
    
    public var items: [String] {
        didSet {
            currentPicker?.items = items
            
            updateSelection()
        }
    }
    
    public override var contentView: UIView? {
        let picker = TextPicker(items: items) { [weak self] in
            self?.selectedText = $0
        }
        
        currentPicker = picker
        
        updateSelection()
        
        return picker
    }
    
    public override var popoverConfiguration: Popover.Configuration {
        var configuration = Popover.Configuration()
        configuration.preferredDirection = .down
        configuration.dismissMode = .tapOnOutsidePopoverAndAnchor
        configuration.animationTransition = .push
        configuration.arrowSize = .zero
        configuration.contentInsets = .zero
        return configuration
    }
    
    public override var drawerConfiguration: DrawerController.Configuration {
        .init(presentationDirection: .up, resizingBehavior: .dismiss)
    }
    
    public override var preferredContentSize: CGSize? {
        guard presentationStyle == .popover else {
            return .zero
        }
        
        let miniumWidth: CGFloat = 50
        
        return CGSize(width: max(miniumWidth, sourceView?.bounds.width ?? miniumWidth), height: 0)
    }
    
    private weak var currentPicker: TextPicker?
        
    public init(items: [String] = [], presentationStyle: PresentationStyle = .popover, presentingViewController: UIViewController? = nil) {
        self.items = items
        
        super.init(presentationStyle: presentationStyle)
        
        self.presentingViewController = presentingViewController
    }
    
    private func updateSelection() {
        guard let currentPicker, let selectedText, let index = items.firstIndex(of: selectedText) else { return }
                
        currentPicker.selectRow(index, inComponent: 0, animated: false)
    }
    
    public override func activate(completion: (() -> Void)? = nil) {
        super.activate(completion: completion)
        
        selectedText = currentPicker?.selectedItem
    }
}
