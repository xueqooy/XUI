//
//  ListBindingCell.swift
//  XUI
//
//  Created by xueqooy on 2023/9/14.
//

import IGListKit
import UIKit
import XUI

/// Cell for wrapping `BindingView`
/// Adjusting view margins by overriding `viewInset`
/// Customize view initialization by overriding `InstantiateView`
/// Do extra initialization works in  `initialized`，dafault do nothing
open class ListBindingCell<View: BindingView>: UICollectionViewCell, ListBindable {
    public private(set) lazy var view = instantiateView()

    open var viewInset: UIEdgeInsets {
        .zero
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalTo(viewInset)
        }

        initialized()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func initialized() {}

    open func instantiateView() -> View {
        View()
    }

    public func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? View.ViewModel else {
            return
        }

        view.bindViewModel(viewModel)
    }
}
