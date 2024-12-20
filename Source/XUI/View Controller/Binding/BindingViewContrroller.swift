//
//  BindingViewContrroller.swift
//  XUI
//
//  Created by xueqooy on 2024/10/18.
//

import Combine
import UIKit

open class BindingViewController<ViewModel>: UIViewController {
    public lazy var cancellables = Set<AnyCancellable>()

    public let viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        performBinding()
    }

    @available(*, deprecated, message: "Use init(viewMode:) Instead")
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, deprecated, message: "Use init(viewMode:) Instead")
    override public required init(nibName _: String?, bundle _: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    // MARK: - Subclass Overrides

    open func setupUI() {}

    open func performBinding() {}
}
