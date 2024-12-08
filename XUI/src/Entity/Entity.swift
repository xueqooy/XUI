//
//  Entity.swift
//  XUI
//
//  Created by xueqooy on 2024/5/31.
//

import Foundation
import IGListDiffKit

public protocol EntityIdentifierConvertible {
    
    var entityIdentifier: String { get }
}

/// Obstract entity
public class Entity: Hashable, ListDiffable, ListCellSizeCacheIdentifiable, CustomStringConvertible {
    
    public let id: EntityIdentifierConvertible
    public let name: String
    
    public init(id: EntityIdentifierConvertible, name: String) {
        self.id = id
        self.name = name
    }
    
    
    // MARK: Equtable
    
    public static func == (lhs: Entity, rhs: Entity) -> Bool {
        lhs.isEqual(toDiffableObject: rhs)
    }
    
    // MARK: Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.entityIdentifier)
        hasher.combine(name)
    }
    
    // MARK: ListCellSizeCacheIdentifiable
    
    public func diffIdentifier() -> NSObjectProtocol {
        id.entityIdentifier as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? Entity else {
            return false
        }
        
        return id.entityIdentifier == other.id.entityIdentifier && name == other.name
    }
    
    
    // MARK: ListCellSizeCacheIdentifiable
    
    public var cellSizeCacheId: NSObjectProtocol {
        name as NSObjectProtocol
    }

    
    // MARK: CustomStringConvertible
    
    public var description: String {
        "\(name)(\(id.entityIdentifier))"
    }
}


// MARK: - PersonaEntity

public class PersonaEntity: Entity {
   
    public let avatarURLConfiguration: AvatarURLConfiguration
    
    public init(id: EntityIdentifierConvertible, name: String, avatarURLConfiguration: AvatarURLConfiguration) {
        self.avatarURLConfiguration = avatarURLConfiguration

        super.init(id: id, name: name)
    }
    
    public override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? PersonaEntity else {
            return false
        }
        
        return id.entityIdentifier.isEqual(id.entityIdentifier) && name == other.name && avatarURLConfiguration == other.avatarURLConfiguration
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        
        hasher.combine(avatarURLConfiguration)
    }
}


// MARK: - GroupEntity

public class GroupEntity: Entity {
   
    public let color: UIColor
            
    public let parentEntityName: String?
    
    public init(id: EntityIdentifierConvertible, name: String, color: UIColor, parentEntityName: String? = nil) {
        self.color = color
        self.parentEntityName = parentEntityName
        
        super.init(id: id, name: name)
    }
    
    public override var cellSizeCacheId: NSObjectProtocol {
        "\(name) - \(String(describing: parentEntityName))" as NSObjectProtocol
    }
    
    public override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? GroupEntity else {
            return false
        }
        
        return id.entityIdentifier == other.id.entityIdentifier && name == other.name && color == other.color && parentEntityName == other.parentEntityName
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        
        hasher.combine(color)
        hasher.combine(parentEntityName)
    }
}


extension String: EntityIdentifierConvertible {
    
    public var entityIdentifier: String { self }
}
