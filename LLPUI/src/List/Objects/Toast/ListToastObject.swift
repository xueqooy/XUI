//
//  ListToastObject.swift
//  CombineCocoa
//
//  Created by xueqooy on 2024/1/5.
//

import Foundation
import IGListDiffKit
import LLPUtils

public class ListToastObject: StateObservableObject, Configurable {
    public typealias Configuration = ToastView.Configuration
    
    public let identifier: String
    public let inset: UIEdgeInsets
    
    @EquatableState
    public var configuration: Configuration
        
    public init(identifier: String = UUID().uuidString, inset: UIEdgeInsets = .init(top: 0, left: .LLPUI.spacing5, bottom: 0, right: .LLPUI.spacing5), configuration: Configuration) {
        self.identifier = identifier
        self.inset = inset
        self.configuration = configuration
    }
}

extension ListToastObject: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        identifier as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        true
    }
}

