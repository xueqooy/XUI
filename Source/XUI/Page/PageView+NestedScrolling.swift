//
//  PageView+NestedScrolling.swift
//  XUI
//
//  Created by xueqooy on 2023/7/25.
//

import Combine
import UIKit

public protocol PageScrollContent: PageContent {
    var pageScrollView: UIScrollView? { get }
}

public extension PageScrollContent {
    var pageScrollView: UIScrollView? { pageContentView as? UIScrollView }
}

extension PageView: NestedScrollingContent {
    public var childScrollView: UIScrollView? {
        childScrollView(for: selectedPageIndex)
    }

    public var childScrollViewDidChangePublisher: AnyPublisher<UIScrollView?, Never>? {
        didSelectPagePublisher.map { index in
            self.childScrollView(for: index)
        }
        .eraseToAnyPublisher()
    }

    public var nonSimultaneousGestureRecognizers: [UIGestureRecognizer]? {
        var result = [UIGestureRecognizer]()
        if let gestureRecognizers = scrollView.gestureRecognizers {
            result.append(contentsOf: gestureRecognizers)
        }

        if let segmentedPageView = self as? SegmentedPageView, let gestureRecognizers = segmentedPageView.segmentControl.collectionView.gestureRecognizers {
            result.append(contentsOf: gestureRecognizers)
        }

        return result
    }

    private func childScrollView(for pageIndex: Int) -> UIScrollView? {
        guard let content = contentForPage(at: pageIndex) else {
            return nil
        }

        if let childScrollViewProvider = content as? PageScrollContent {
            return childScrollViewProvider.pageScrollView
        } else {
            return content as? UIScrollView
        }
    }
}
