//
//  BindingViewContrroller.swift
//  LLPUI
//
//  Created by xueqooy on 2024/10/18.
//

import UIKit
import Combine

open class BindingViewController<ViewModel> : UIViewController {
    
    public lazy var cancellables = Set<AnyCancellable>()
    
    public let viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        performBinding()
    }
    
    @available(*, deprecated, message: "Use init(viewMode:) Instead")
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, deprecated, message: "Use init(viewMode:) Instead")
    public required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    
    // MARK: - Subclass Overrides
    
    open func setupUI() {
    }
    
    open func performBinding() {
    }
    
    
}
