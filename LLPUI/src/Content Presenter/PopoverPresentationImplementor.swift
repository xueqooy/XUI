//
//  PopoverPresentationImplementor.swift
//  LLPUI
//
//  Created by xueqooy on 2023/12/29.
//

import Foundation
import LLPUtils
import Combine

class PopoverPresentationImplementor: PresentationImplementor {
    
    private lazy var popover: Popover = {
        let popover = Popover(configuration: presenter.popoverConfiguration)
        cancelable = popover.$isShowing.didChange
            .sink { [weak self] isShowing in
                self?.presenter.isActive = isShowing
            }
    
        return popover
    }()
    
    private var cancelable: AnyCancellable?
    
    override func activate(completion: (() -> Void)? = nil) {
        guard let sourceView = presenter.sourceView, let presentingViewController = presenter.finalPresentingViewController else {
            return
        }
        guard !popover.isShowing else {
            completion?()
            return
        }
        
      
        // Present popover
        if let contentController = presenter.contentController {
            popover.show(contentController, preferredContentSize: presenter.preferredContentSize, in: presentingViewController, from: sourceView, completion: completion)
        } else if let contentView = presenter.contentView {
            popover.show(contentView, preferredContentSize: presenter.preferredContentSize, in: presentingViewController.view, from: sourceView, completion: completion)
        } else {
            Asserts.failure("Need to implement contentController or contentView", tag: "LLPUI")
        }
    }
    
    override func deactivate(completion: (() -> Void)? = nil) {
        if popover.isShowing {
            popover.hide(completion: completion)
        } else {
            completion?()
        }
    }
}
