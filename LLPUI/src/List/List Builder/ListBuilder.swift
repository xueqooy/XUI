//
//  ListManager.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/25.
//

import UIKit
import SnapKit
import Combine
import IGListKit

/** 
 `BindingListBuilder` and `GenericListBuilder` are suitable for quickly building lists, but are not recommended for complex scenarios involving reusable units.
 Utilizing the approach of inheriting from` ListSectionController` or `BindingListSectionController` is more advantageous for component reusability in such situations.
 
 */
public protocol ListBuilder {
    
    associatedtype Configuration
    
    var configuration: Configuration { get }

    var listController: ListController { get }
    
    var objects: [Object] { set get }
}


public extension ListBuilder {
    
    typealias Object = ListDiffable
    typealias Cell = UICollectionViewCell
    typealias SectionStyleProvider = (_ object: Object) -> ListSectionStyle
    
    @MainActor var objects: [Object] {
        set { listController.objects = newValue }
        get { listController.objects }
    }
    
    @MainActor func addList(to viewController: UIViewController, layout: ((_ make: ConstraintMaker) -> Void)? = nil) {
        listController.viewController = viewController
        
        let listView = listController.listView
        
        viewController.view.addSubview(listView)
        listView.snp.makeConstraints { make in
            if let layout = layout {
                layout(make)
            } else {
                make.edges.equalToSuperview()
            }
        }
    }
}
