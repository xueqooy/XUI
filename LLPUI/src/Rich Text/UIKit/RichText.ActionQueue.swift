//
//  ActionQueue.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/18.
//

import Foundation

extension RichText {
    // Ensure the call order for touchesBegan -> Action -> touchesEnded
    class ActionQueue {
        static let main = ActionQueue()
        
        typealias Handler = () -> Void
        
        private var handler: Handler?
        
        func began(_ handler: Handler) {
            handler()
        }
        
        func action(_ handler: @escaping Handler) {
            self.handler = handler
        }
        
        func ended(_ handler: @escaping Handler) {
            handler()
            
            self.handler?()
        }
        
        func cancelled(_ handler: @escaping Handler) {
            self.handler = nil
            handler()
        }
    }

}
