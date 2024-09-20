//
//  PresentationImplementor.swift
//  LLPUI
//
//  Created by xueqooy on 2023/12/29.
//

import Foundation

class PresentationImplementor {
    
    unowned let presenter: ContentPresenter
    
    init(presenter: ContentPresenter) {
        self.presenter = presenter
    }
    
    func activate(completion: (() -> Void)? = nil) {
    }
    
    func deactivate(completion: (() -> Void)? = nil) {
    }
}
