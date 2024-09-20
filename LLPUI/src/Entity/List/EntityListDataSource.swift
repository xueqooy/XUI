//
//  EntityListDataSource.swift
//  LLPUI
//
//  Created by xueqooy on 2024/7/1.
//

import Foundation

public protocol EntityListDataSource {
            
    func getEntities(withQuery query: String?) async -> [Entity]
}


extension Array: EntityListDataSource where Element == Entity {
    
    public func getEntities(withQuery query: String?) async -> [Entity] {
        if let query = query, !query.isEmpty {
            return self.filter { $0.name.lowercased().contains(query.lowercased()) }
        } else {
            return self
        }
    }
}
