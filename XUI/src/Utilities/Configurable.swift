//
//  Configurable.swift
//  XUI
//
//  Created by xueqooy on 2024/1/10.
//

import Foundation

public protocol Configurable: AnyObject {
    associatedtype Configuration
    
    var configuration: Configuration { set get }
    
    /// When multiple properties of configuration need to be modified at once, try to call this method as much as possible
    func update(_ modifier: (inout Configuration) -> Void)
}

public extension Configurable {
    func update(_ modifier: (inout Configuration) -> Void) {
        modifier(&configuration)
    }
}
