//
//  NestedHeaderContainerView.swift
//  XUI
//
//  Created by xueqooy on 2023/7/20.
//

import UIKit

class NestedHeaderContainerView: UIControl {
    var headerView: NestedScrollingHeader? {
        didSet {
            oldValue?.removeFromSuperview()

            guard let headerView = headerView else {
                return
            }

            addSubview(headerView)
            headerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()

                if headerView.headerHeight != .XUI.automaticDimension {
                    make.height.equalTo(headerView.headerHeight)
                }
            }
        }
    }

    weak var contentContainerView: NestedContentContainerView?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        contentContainerView?.contentView?.childScrollView?.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        contentContainerView?.contentView?.childScrollView?.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        contentContainerView?.contentView?.childScrollView?.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        contentContainerView?.contentView?.childScrollView?.touchesCancelled(touches, with: event)
    }
}
