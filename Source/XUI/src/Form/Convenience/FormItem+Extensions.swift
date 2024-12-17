//
//  FormItem+Extensions.swift
//  XUI
//
//  Created by xueqooy on 2024/4/18.
//

import UIKit
import XKit
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
    func bindingCustomSpacingAfter<T, V>(to publisher: T, transform: @escaping (V) -> CGFloat) -> Self where T : Publisher, T.Output == V, T.Failure == Never {
        bindinCustomSpacingCancellableAssociation[self] =
        publisher
            .map(transform)
            .sink { [weak self] spacing in
                self?.customSpacingAfter = spacing
            }
        
        return self
    }
    
    @discardableResult
    func bindingCustomSpacingAfter<T>(to publisher: T) -> Self where T : Publisher, T.Output == CGFloat, T.Failure == Never {
        bindingCustomSpacingAfter(to: publisher) { $0 }
    }
    
    @discardableResult
    func bindingHidden<T, V>(to publisher: T, transform: @escaping (V) -> Bool) -> Self where T : Publisher, T.Output == V, T.Failure == Never {
        bindingHiddenCancellableAssociation[self] =
        publisher
            .map(transform)
            .sink { [weak self] isHidden in
                self?.isHidden = isHidden
            }
        
        return self
    }
    
    @discardableResult
    func bindingHidden<T>(to publisher: T, toggled: Bool = false) -> Self where T : Publisher, T.Output == Bool, T.Failure == Never {
        bindingHidden(to: publisher) {
            toggled ? !$0 : $0
        }
    }
}

