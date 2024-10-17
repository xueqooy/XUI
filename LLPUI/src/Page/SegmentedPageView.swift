//
//  SegmentedPageView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/7/18.
//

import UIKit
import LLPUtils

public protocol SegmentedPageViewDataSource: PageViewDataSource {
    
    func pageView(_ segmentedPageView: SegmentedPageView, segmentItemForPageAt index: Int) -> SegmentedPageView.SegmentItem
}


/// A page view with segmented control, the displayed content is loaded lazily.
/// The pageContent can be either `UIView` or `UIViewController`
/// `UIViewController` Appearance transition will be automatically managed
open class SegmentedPageView: PageView {
    
    public typealias SegmentItem = SegmentControl.Item
    
    public enum SegmentControlLayoutMode {
        case centeredCompactly, fill
    }
    
    private(set) lazy var segmentControl: SegmentControl = {
        let segmentControl = SegmentControl(style: .page)
        segmentControl.automaticallyUpdateIndicatorPostion = false
        segmentControl.selectionChanged = { [weak self] control in
            guard let self = self else {
                return
            }
            
            guard control.selectedSegmentIndex != self.selectedPageIndex else {
                return
            }
            
            self.selectPage(at: control.selectedSegmentIndex, animated: false)
        }
        return segmentControl
    }()
    
    private let segmentControlLayoutMode: SegmentControlLayoutMode
    
    public init(segmentControlLayoutMode: SegmentControlLayoutMode = .centeredCompactly) {
        self.segmentControlLayoutMode = segmentControlLayoutMode
        
        super.init(frame: .zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initialize() {
        addSubview(segmentControl)
        segmentControl.snp.makeConstraints { make in
            switch segmentControlLayoutMode {
            case .centeredCompactly:
                make.top.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
                make.centerX.equalToSuperview()
            case .fill:
                make.top.leading.trailing.equalToSuperview()
            }
        }
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        segmentControl.setNeedsLayout()
        segmentControl.layoutIfNeeded()
        
        updateSegmentIndicatorPosition()
    }
    
    public override func reloadData() {
        super.reloadData()
        
        reloadSegmentItems()
        
        segmentControl.selectedSegmentIndex = selectedPageIndex

        updateSegmentIndicatorPosition()
    }
    
    public func reloadSegmentItems() {
        guard let dataSource = dataSource as? SegmentedPageViewDataSource else {
            Asserts.failure("dataSource need conform to SegmentedPageViewDataSource")
            segmentControl.items.removeAll()
            return
        }
        
        let items = (0..<numberOfPages).map {
            dataSource.pageView(self, segmentItemForPageAt: $0)
        }
        segmentControl.items = items
    }
    
    public override func selectPage(at index: Int, animated: Bool) {
        super.selectPage(at: index, animated: animated)
        
        segmentControl.selectedSegmentIndex = index
    }
    
    // MARK: - Private
    
    private func updateSegmentIndicatorPosition() {
        guard scrollView.bounds.width > 0 else {
            return
        }
        
        let scrollOffset = scrollView.contentOffset.x
        let pageWidth = scrollView.bounds.width
        let leftPageIndex = max(0.0, floor(scrollOffset / pageWidth))
        let rightPageIndex = min(CGFloat(segmentControl.items.count) - 1.0,  ceil(scrollOffset / pageWidth))
        let fraction = abs(scrollOffset - leftPageIndex * pageWidth) / pageWidth
        
        segmentControl.updateIndicatorPosition(fromIndex: Int(leftPageIndex), toIndex: Int(rightPageIndex), fraction: fraction)
    }
}


extension SegmentedPageView {
        
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSegmentIndicatorPosition()
        
        super.scrollViewDidScroll(scrollView)
    }
}
