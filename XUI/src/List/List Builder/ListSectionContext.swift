//
//  ListSectionContext.swift
//  XUI
//
//  Created by xueqooy on 2024/1/26.
//

import Foundation
import IGListKit
import Combine

/**
 The context of Section Controller allows for performing operations such as `update` and `validateLayout` during the lifecycle of Section Controller
 */
public class ListSectionContext {
    
    public typealias Object = ListBuilder.Object
    
    public var object: Object {
        sectionController.object as! Object
    }
    
    /// The cancellables associated with the section
    public var cancellables: Set<AnyCancellable> {
        get {
            sectionController.cancellables
        }
        set {
            sectionController.cancellables = newValue
        }
    }
    
    public var sectionContainerWidth: CGFloat {
        sectionController.sectionContainerWidth
    }
    
    public var sectionContainerHeight: CGFloat {
        sectionController.sectionContainerHeight
    }
    
    public var scrollCrossAxisExtent: CGFloat {
        sectionController.scrollCrossAxisExtent
    }
    
    public var section: Int {
        sectionController.section
    }
            
    let sectionController: (any _PrivateSectionControllerProtocol)
    
    init(sectionController: any _PrivateSectionControllerProtocol) {
        self.sectionController = sectionController
    }
    
    /// Refresh the section corresponding to the object
    @MainActor public func update(for object: Object, animated: Bool) async -> Bool {
        await sectionController.collectionContext.performBatch(animated: animated) { batchContext in
            batchContext.reload(self.sectionController)
        }
    }
    
    /// Recalculate the size of the section corresponding to the object
    @MainActor public func invalidateLayout(for object: Object) async -> Bool {
        await sectionController.collectionContext.invalidateLayout(for: sectionController)
    }
}
