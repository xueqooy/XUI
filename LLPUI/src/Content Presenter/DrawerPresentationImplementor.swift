//
//  DrawerPresentationImplementor.swift
//  LLPUI
//
//  Created by xueqooy on 2023/12/29.
//

import UIKit
import LLPUtils

class DrawerPresentationImplementor: PresentationImplementor {
    
    private weak var currentDrawer: DrawerController?

    override func activate(completion: (() -> Void)? = nil) {
        guard let sourceView = presenter.sourceView, let presentingViewController = presenter.finalPresentingViewController else {
            return
        }
        guard currentDrawer == nil else {
            
            completion?()
            return
        }
                
        // Configure drawer
        let drawer = DrawerController(sourceView: sourceView, sourceRect: presenter.sourceRect ?? sourceView.bounds, configuration: presenter.drawerConfiguration)
        drawer.delegate = self
        
        if let preferredContentSize = presenter.preferredContentSize {
            drawer.preferredContentSize = preferredContentSize
        }
        
        if let contentController = presenter.contentController {
            presenter.isActive = true
            
            drawer.contentController = contentController
            
        } else if let contentView = presenter.contentView {
            presenter.isActive = true
            
            drawer.contentView = contentView

        } else {
            Asserts.failure("Need to implement contentController or contentView", tag: "LLPUI")
        }
        
        // Present drawer
        presentingViewController.present(drawer, animated: true, completion: completion)
        
        currentDrawer = drawer
    }
    
    override func deactivate(completion: (() -> Void)? = nil) {
        presenter.isActive = false
        
        if let drawer = currentDrawer {
            currentDrawer = nil
            drawer.dismiss(animated: true, completion: completion)
        } else {
            completion?()
        }
    }
}

extension DrawerPresentationImplementor: DrawerControllerDelegate {
    public func drawerControllerWillDismiss(_ controller: DrawerController) {
        deactivate()
    }
}
