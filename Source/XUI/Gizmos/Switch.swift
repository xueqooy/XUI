//
//  Switch.swift
//  XUI
//
//  Created by xueqooy on 2023/3/10.
//

import Foundation
import UIKit

open class Switch: UISwitch {
    override open var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }

            for subview in subviews {
                subview.alpha = isEnabled ? 1.0 : 0.5
            }
        }
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    override public init(frame _: CGRect) {
        super.init(frame: .zero)

        initialize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    private func initialize() {
        onTintColor = Colors.green

        subviews.first?.subviews.first?.backgroundColor = Colors.disabledText

        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
}
