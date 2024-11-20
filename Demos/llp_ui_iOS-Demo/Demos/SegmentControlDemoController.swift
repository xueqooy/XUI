//
//  SegmentControlDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/2/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI

class SegmentControlDemoController: DemoController {
    var pagedSegmentControl: SegmentControl!
    let pagedScrollView = UIScrollView()
    let pageControl = PageControl()

    override func viewDidLoad() {
        super.viewDidLoad()
                        
        let firstLevelControl = SegmentControl(style: .page, items: ["All", .badgedText("In Progress", value: "10"), .text("Completed"), .badgedText("Overdue")])
        firstLevelControl.selectedSegmentIndex = 0
        addTitle("First Level")
        addRow(firstLevelControl)
        addSeparator()
        
        let secondLevelControl = SegmentControl(style: .tab, items: ["Student", .badgedText("Teacher", value: "99+")])
        secondLevelControl.selectedSegmentIndex = 0
        addTitle("Second Level")
        addRow(secondLevelControl)
        addSeparator()
        
        let fillEquallyControl = SegmentControl(style: .page, fillEqually: true, items: ["Username or Email", "Mobile Number"])
        fillEquallyControl.selectedSegmentIndex = 0
        addTitle("Fill Equally")
        addRow(fillEquallyControl, alignment: .fill)
        addSeparator()

        let toggleControl = SegmentControl(style: .toggle, items: ["AM", "PM"])
        toggleControl.selectedSegmentIndex = 0
        addTitle("Toggle")
        addRow(toggleControl)
        addSeparator()
        
        let items: [SegmentControl.Item] = [.badgedText("Page 1", value: "10"), "Page 2", "Page 3", .badgedText("Page 4"), "Page 5", .badgedText("Page 6", value: "1")]
        pagedSegmentControl = SegmentControl(items: items)
        pagedSegmentControl.selectionChanged = { [weak self] bar in
            if bar.selectedSegmentIndex != .LLPUI.noSelection {
                self?.scrollToPage(bar.selectedSegmentIndex)
            }
        }
        pagedSegmentControl.addTarget(self, action: #selector(Self.pageSegmentControlSelectionChanged(_:)), for: .valueChanged)
        pagedSegmentControl.selectedSegmentIndex = 0
        DispatchQueue.main.execute {
            self.pagedSegmentControl.automaticallyUpdateIndicatorPostion = false
        }
        addTitle("Interact With Paged Scroll View")
        addRow(pagedSegmentControl)
        
        pagedScrollView.showsVerticalScrollIndicator = false
        pagedScrollView.showsHorizontalScrollIndicator = false
        pagedScrollView.delegate = self
        pagedScrollView.isPagingEnabled = true
        addRow(pagedScrollView)
        let pageWidth = view.bounds.width - contentInset.horizontal
        let pageHeight = 300.0
        pagedScrollView.snp.makeConstraints { make in
            make.width.equalTo(pageWidth)
            make.height.equalTo(pageHeight)
        }
        pagedScrollView.contentSize = CGSize(width: pageWidth * CGFloat(items.count), height: pageHeight)
        
        for i in 0..<items.count {
            let label = UILabel()
            label.textColor = .randomColor()
            label.text = "\(i + 1)"
            label.textAlignment = .center
            label.font = Fonts.font(ofSize: 50, weight: .bold)
            pagedScrollView.addSubview(label)
            label.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.width.equalTo(pageWidth)
                make.height.equalTo(pageHeight)
                make.centerX.equalToSuperview().offset(CGFloat(i) * pageWidth)
            }
        }
        
        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(Self.pageControlValueChanged(_:)), for: .valueChanged)
        pagedScrollView.superview?.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    private func scrollToPage(_ page: Int) {
        pageControl.currentPage = page
        pagedScrollView.setContentOffset(CGPoint(x: CGFloat(page) * pagedScrollView.bounds.width, y: 0.0), animated: true)
    }
    
    @objc private func pageSegmentControlSelectionChanged(_ sender: SegmentControl) {
        print(sender.selectedSegmentIndex)
    }
    
    @objc private func pageControlValueChanged(_ sender: PageControl) {
        pagedSegmentControl.selectedSegmentIndex = sender.currentPage
    }
}

extension SegmentControlDemoController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.x
        
        let width = scrollView.bounds.width
        let fromPage = max(0.0, floor(scrollOffset / width))
        let toPage = min(CGFloat(pagedSegmentControl.items.count) - 1.0,  ceil(scrollOffset / width))
        let fraction = abs(scrollOffset - fromPage * width) / width
        
        pagedSegmentControl.updateIndicatorPosition(fromIndex: Int(fromPage), toIndex: Int(toPage), fraction: fraction)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("begin dragging")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("end dragging")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("end scrolling")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("end decelerating")
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        pagedSegmentControl.selectedSegmentIndex = Int(page)
    }
}
