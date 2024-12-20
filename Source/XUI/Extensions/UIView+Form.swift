//
//  UIView+Form.swift
//  XUI
//
//  Created by xueqooy on 2023/8/1.
//

import SnapKit
import UIKit
import XKit

public extension UIView {
    @discardableResult func addForm(scrollingBehavior: FormView.ContentScrollingBehavior = .normal, respectsSafeArea: Bool = true, configure: ((_ formView: FormView) -> Void)? = nil, @ArrayBuilder<FormComponent> populate: () -> [FormComponent]) -> FormView {
        let formView = FormView(contentScrollingBehavior: scrollingBehavior)
        configure?(formView)

        addSubview(formView)
        formView.snp.makeConstraints { make in
            if respectsSafeArea {
                make.edges.equalTo(self.safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
        }

        formView.populate(components: populate)

        return formView
    }
}
