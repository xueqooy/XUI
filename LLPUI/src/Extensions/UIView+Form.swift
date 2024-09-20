//
//  UIView+Form.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/1.
//

import UIKit
import LLPUtils
import SnapKit

public extension UIView {
    @discardableResult func addForm(scrollingBehavior: FormView.ContentScrollingBehavior = .normal, configure: ((_ formView: FormView) -> Void)? = nil, layout: ((_ make: ConstraintMaker) -> Void)? = nil, @ArrayBuilder<FormComponent> populate: () -> [FormComponent]) -> FormView {
        let formView = FormView(contentScrollingBehavior: scrollingBehavior)
        configure?(formView)
        
        addSubview(formView)
        formView.snp.makeConstraints { make in
            if let layout = layout {
                layout(make)
            } else {
                make.edges.equalToSuperview()
            }
        }
        
        formView.populate(components: populate)
        
        return formView
    }
}
