//
//  BindingListSectionContext.swift
//  XUI
//
//  Created by xueqooy on 2024/1/28.
//

import Foundation
import IGListKit

public class BindingListSectionContext: ListSectionContext {
    var viewModels: [BindingListBuilder.ViewModel] {
        (sectionController as! _BindingSectionController).viewModels
    }

    override public func update(for _: ListSectionContext.Object, animated: Bool) async -> Bool {
        await (sectionController as! _BindingSectionController).update(animated: animated)
    }
}
