//
//  MainTabPage.swift
//  llp_x_cloud_assemble_ios
//
//  Created by xueqooy on 2024/10/17.
//

import UIKit
import XKit
import Combine

open class Tab {
    
    public struct Identifier : Hashable, Equatable, RawRepresentable {

        public var rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public typealias TabItem = SegmentControl.Item
    
    @EquatableState
    public var tabItem: TabItem!
    
    public var navigationController: UINavigationController {
        if let cachedNavigationController {
            return cachedNavigationController
        }
        
        // Cache the navigationController
        let navigationController = createNavigationController()
        cachedNavigationController = navigationController
        
        controllerDidLoad()
        
        return navigationController
    }
    
    private var cachedNavigationController: UINavigationController?
    
    private var cachedRootViewController: UIViewController?
    
    private var lifecycleSubscription: AnyCancellable?
        
    public let identifier: Identifier
    
    public init(identifier: Identifier) {
        self.identifier = identifier
        self.tabItem = defaultTabItem
    }
    
    private func createNavigationController() -> UINavigationController {
        let rootViewController = createRootViewController()
                
        lifecycleSubscription = rootViewController.viewStatePublisher
            .sink { [weak self] viewState in
                guard let self else { return }
                
                print("Main tab page [\(self.tabItem.text)] -> \(viewState)")
            }
        
        let navigationController = navigationControllerClass.init(rootViewController: rootViewController)
        
        return navigationController
    }
    
    // MARK: - Subclass Overrides
    
    open var navigationControllerClass: UINavigationController.Type {
        UINavigationController.self
    }
    
    open var defaultTabItem: TabItem {
        fatalError("Subclass override")
    }
    
    open func createRootViewController() -> UIViewController {
        fatalError("Subclass override")
    }
    
    open func controllerDidLoad() {
    }
}
