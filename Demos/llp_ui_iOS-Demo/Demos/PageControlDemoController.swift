//
//  PageControlDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/4/9.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI
import LLPUtils

class PageControlDemoController: DemoController {
        
    override func viewDidLoad() {
        super.viewDidLoad()

        let systemPageControl = UIPageControl()
        systemPageControl.currentPageIndicatorTintColor = Colors.teal
        systemPageControl.pageIndicatorTintColor = Colors.teal.withAlphaComponent(0.3)
        systemPageControl.numberOfPages = 15
        
        let pageControl = PageControl()
        pageControl.numberOfPages = 15
        
        let nextPageButton = Button(designStyle: .primarySmall, title: "➡️") { _ in

            pageControl.currentPage = pageControl.currentPage + 1
            systemPageControl.currentPage = systemPageControl.currentPage + 1
        }

        let prePageButton = Button(designStyle: .primarySmall, title: "⬅️") { _ in
    
            pageControl.currentPage = pageControl.currentPage - 1
            systemPageControl.currentPage = systemPageControl.currentPage - 1
        }
        
        addRow(createLableAndInputFieldAndButtonRow(labelText: "Pages", placehoder: "15", keyboardType: .numberPad, buttonTitle: "Confirm", buttonAction: { value in
            let pages = Int(value) ?? 15
            
            systemPageControl.numberOfPages = pages
            pageControl.numberOfPages = pages
        }))
        addSeparator()
        addTitle("UIKit.UIPageControl")
        addRow(systemPageControl)
        addTitle("LLPUI.PageControl")
        addRow(pageControl)
        addSpacer()
        addRow([prePageButton, nextPageButton], itemSpacing: 20, distribution: .fillEqually)
    
    }
}
