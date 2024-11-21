//
//  SegmentPage.swift
//  LLPUI
//
//  Created by xueqooy on 2024/10/18.
//

import LLPUtils
import Combine

open class Page {
    
    public typealias SegmentItem = SegmentControl.Item
    
    @EquatableState
    public var segmentItem: SegmentItem!
    
    /// The content view controller of page
    public var viewController: UIViewController {
        if let cachedViewController {
            return cachedViewController
        }
        
        // Cache the content
        let viewController = createViewController()
        
        cachedViewController = viewController
        
        lifecycleSubscription = viewController.viewStatePublisher
            .sink { [weak self] viewState in
                guard let self else { return }
                
                print("Sub Page [\(self.segmentItem.text)] -> \(viewState)")
            }
        
        return viewController
    }
    
    private var cachedViewController: UIViewController?
        
    private var lifecycleSubscription: AnyCancellable?
    
    public init() {
        segmentItem = defaultSegmentItem
    }
    
    // MARK: - Subclass Overrides
    
    open var defaultSegmentItem: SegmentItem {
        fatalError("Subclass override")
    }
    
    /// Create the page content to be displayed, GroupPage will cache this value
    open func createViewController() -> UIViewController {
        fatalError("Subclass override")
    }
}
