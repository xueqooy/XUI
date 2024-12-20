//
//  TextField.swift
//  XUI
//
//  Created by xueqooy on 2023/3/10.
//

import UIKit

open class TextField: UITextField {
    /// https://stackoverflow.com/questions/53566570/ios-12-suggested-strong-password-textfield-delegate-callback-for-choose-my-own-p/76313134#76313134
    private var hasAutomaticStrongPassword: Bool = false {
        didSet {
            if oldValue && !hasAutomaticStrongPassword {
                // After user selecting "Choose My Own Password"
                // Manually triggering changes
                sendActions(for: .editingChanged)
                _ = delegate?.textField?(self, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "")
            }
        }
    }

    override public init(frame _: CGRect) {
        super.init(frame: .zero)

        textStyleConfiguration = .textInput
        tintColor = Colors.teal
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        hasAutomaticStrongPassword = subviews.first { subview in
            NSStringFromClass(subview.classForCoder).contains("KBASP" + "Cover")
        } != nil
    }
}
