//
//  FormItem+Extensions.swift
//  LLPUI
//
//  Created by xueqooy on 2024/4/18.
//

import UIKit
import LLPUtils
import Combine

private let bindinCustomSpacingCancellableAssociation = Association<AnyCancellable>()

private let bindingHiddenCancellableAssociation = Association<AnyCancellable>()

public extension FormItem {
    
    @discardableResult
    func settingCustomSpacingAfter(_ customSpacingAfter: CGFloat?) -> Self {
        self.customSpacingAfter = customSpacingAfter
        return self
    }
    
    @discardableResult
    func settingHidden(_ hidden: Bool) -> Self {
        self.isHidden = hidden
        return self
    }
    
    @discardableResult
    func bindingCustomSpacingAfter<T>(to publisher: some Publisher<T, Never>, transform: @escaping (T) -> CGFloat) -> Self {
        bindinCustomSpacingCancellableAssociation[self] =
        publisher
            .map(transform)
            .sink { [weak self] spacing in
                self?.customSpacingAfter = spacing
            }
        
        return self
    }
    
    @discardableResult
    func bindingCustomSpacingAfter(to publisher: some Publisher<CGFloat, Never>) -> Self {
        bindingCustomSpacingAfter(to: publisher) { $0 }
    }
    
    @discardableResult
    func bindingHidden<T>(to publisher: some Publisher<T, Never>, transform: @escaping (T) -> Bool) -> Self {
        bindingHiddenCancellableAssociation[self] =
        publisher
            .map(transform)
            .sink { [weak self] isHidden in
                self?.isHidden = isHidden
            }
        
        return self
    }
    
    @discardableResult
    func bindingHidden(to publisher: some Publisher<Bool, Never>, toggled: Bool = false) -> Self {
        bindingHidden(to: publisher) {
            toggled ? !$0 : $0
        }
    }
}

