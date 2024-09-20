//
//  Bindable.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/21.
//

import UIKit
import Combine
import LLPUtils
import IGListKit

public protocol Bindable {
    associatedtype ViewModel
    
    func bindViewModel(_ viewModel: ViewModel)
}


private let bindingCancellablesAssociation = Association<Set<AnyCancellable>>(wrap: .retain)
private let viewModelAssociation = Association<Any>(wrap: .retain)

public extension Bindable where Self : UIView {
    var bindingCancellables: Set<AnyCancellable> {
        get {
            if let cancellables = bindingCancellablesAssociation[self] {
                return cancellables
            }
            
            let cancellables = Set<AnyCancellable>()
            bindingCancellablesAssociation[self] = cancellables
            return cancellables
        }
        set {
            bindingCancellablesAssociation[self] = newValue
        }
    }
    
    var viewModel: ViewModel? {
        viewModelAssociation[self] as? ViewModel
    }
    
    func updateViewModel(_ viewModel: ViewModel) {
        bindingCancellablesAssociation[self] = nil
        viewModelAssociation[self] = viewModel
    }
}

public typealias BindingView = UIView & Bindable


