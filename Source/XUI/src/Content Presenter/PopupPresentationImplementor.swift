//
//  PopupPresentationImplementor.swift
//  XUI
//
//  Created by xueqooy on 2024/4/8.
//

import Foundation
import XKit
import Combine

class PopupPresentationImplementor: PresentationImplementor {
    
    private weak var currentPopup: PopupController?

    private var cancellable: AnyCancellable?
    
    override func activate(completion: (() -> Void)? = nil) {
        guard let presentingViewController = presenter.finalPresentingViewController else {
            return
        }
        guard currentPopup == nil else {
            completion?()
            return
        }
                
        // Configure popup
        let popup = PopupController(configuration: presenter.popupConfiguration)
        
        if let preferredContentSize = presenter.preferredContentSize {
            popup.preferredContentSize = preferredContentSize
        }
        
        if let contentController = presenter.contentController {
            presenter.isActive = true
            
            popup.contentController = contentController
            
        } else if let contentView = presenter.contentView {
            presenter.isActive = true
            
            popup.contentView = contentView

        } else {
            Asserts.failure("Need to implement contentController or contentView", tag: "XUI")
        }
        
        cancellable = popup.viewStatePublisher.sink { [weak popup, weak self] viewState in
            guard let self, let popup, viewState == .willDisappear && popup.isBeingDismissed else {
                return
            }
            
            self.deactivate()
        }
        
        // Present popup
        presentingViewController.present(popup, animated: true, completion: completion)
        
        currentPopup = popup
    }
    
    override func deactivate(completion: (() -> Void)? = nil) {
        presenter.isActive = false
        
        if let popup = currentPopup {
            currentPopup = nil
            popup.dismiss(animated: true, completion: completion)
        } else {
            completion?()
        }
    }
}
