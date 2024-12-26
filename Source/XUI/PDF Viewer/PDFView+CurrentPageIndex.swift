//
//  PDFView+CurrentPageIndex.swift
//  XUI
//
//  Created by xueqooy on 2024/12/26.
//

import PDFKit

extension PDFView {
    var currentPageIndex: Int {
        guard let document else { return 0 }
                
        if let currentPage {
            let index = document.index(for: currentPage)
            if index != NSNotFound {
                return index
            }
        }
        
        return 0
    }
}
