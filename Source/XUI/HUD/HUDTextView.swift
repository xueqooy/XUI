//
//  HUDTextView.swift
//  XUI
//
//  Created by xueqooy on 2024/6/18.
//

import Foundation
import UIKit

class HUDTextView: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)

        textStyleConfiguration = .hudText
        numberOfLines = 0
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
