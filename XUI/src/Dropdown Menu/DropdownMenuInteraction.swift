//
//  DropdownMenuInteraction.swift
//  XUI
//
//  Created by xueqooy on 2024/5/7.
//

import UIKit
import Combine

public class DropdownMenuInteraction: NSObject, UIInteraction {
    
    public weak var view: UIView?
        
    public var dropdownMenu: DropdownMenu
    
    private let interactionWillStartHandler: ((DropdownMenuInteraction) -> Void)?
    
    private var cancellable: AnyCancellable?
    
    public init(dropdownMenu: DropdownMenu, interactionWillStartHandler: ((DropdownMenuInteraction) -> Void)? = nil) {
        self.dropdownMenu = dropdownMenu
        self.interactionWillStartHandler = interactionWillStartHandler
    }
        
    public func willMove(to view: UIView?) {
    }
    
    public func didMove(to view: UIView?) {
        self.view = view
        
        cancellable = nil
        
        if let control = view as? UIControl {
            cancellable = control.controlEventPublisher(for: .touchUpInside)
                .sink { [weak self] _ in
                    guard let self else { return }
                    
                    self.start()
                }
        }
    }
    
    public func start() {
        guard let view = self.view else {
            return
        }
        
        interactionWillStartHandler?(self)
        dropdownMenu.show(from: view)
    }
    
    public func cancel() {
        dropdownMenu.hide()
    }
}
