//
//  PDFFullscreenViewController.swift
//  XUI
//
//  Created by xueqooy on 2024/12/26.
//

import UIKit

class PDFFullscreenViewController: UIViewController {
    var viewSizeChangedHandler: (() -> Void)?
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        .fade
    }
    
    let controlBar = PDFFullscreenControlBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(controlBar) { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        view.bringSubviewToFront(controlBar)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { _ in
            self.viewSizeChangedHandler?()
        }
    }
}
