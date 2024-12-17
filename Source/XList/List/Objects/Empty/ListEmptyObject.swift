//
//  EmptyObject.swift
//  CombineCocoa
//
//  Created by xueqooy on 2024/1/5.
//

import Foundation
import IGListDiffKit
import XKit
import XUI

/// Empty view used in vertical or horizontal list, but not recommended to use it in the horizontal list
public class ListEmptyObject: StateObservableObject {
    
    public let identifier: String
    
    @EquatableState
    public var configuration: EmptyView.Configuration
   
    public init(identifier: String = UUID().uuidString, configuration: EmptyView.Configuration) {
        self.identifier = identifier
        self.configuration = configuration
    }
}

extension ListEmptyObject: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        identifier as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        true
    }
}
