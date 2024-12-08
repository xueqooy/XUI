//
//  UIViewController+ViewState.swift
//  XUI
//
//  Created by xueqooy on 2023/4/19.
//

import UIKit
import XKit
import Combine

private extension UIViewController {
    @objc class func XUI_load_uiviewController_viewstate() {
        Self.setup_viewState()
    }
}

private let viewStateSubjectAssociation = Association<CurrentValueSubject<UIViewController.ViewState, Never>>()

public extension UIViewController {
    private struct AssociatedKey {
        static var viewStateSubject = "XUI.viewStateSubject"
    }
    
    enum ViewState {
        case notLoaded, didLoad, willAppear, isAppearing, didAppear, willDisappear, didDisappear
    }
    
    private var viewStateSubject: CurrentValueSubject<ViewState, Never> {
        if let subject = viewStateSubjectAssociation[self] {
            return subject
        }
        
        let subject = CurrentValueSubject<ViewState, Never>(.notLoaded)
        viewStateSubjectAssociation[self] = subject
        
        return subject
    }
    
    var viewStatePublisher: AnyPublisher<ViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    var viewState: ViewState {
        viewStateSubject.value
    }
    
    private class func setup_viewState() {
        Once.execute("UIViewController+ViewState_setup_viewState") {
            overrideImplementation(Self.self, selector: #selector(Self.viewDidLoad)) { originClass, originSelector, originIMPProvider in
                return ({ (object: Self) -> Void in
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (Self, Selector) -> Void).self)
                    oriIMP(object, originSelector)
                    
                    object.viewStateSubject.send(.didLoad)
                } as @convention(block) (Self) -> Void)
            }
            
            overrideImplementation(Self.self, selector: #selector(Self.viewWillAppear(_:))) { originClass, originSelector, originIMPProvider in
                return ({ (object: Self, animated: Bool) -> Void in
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (Self, Selector, Bool) -> Void).self)
                    oriIMP(object, originSelector, animated)
                    
                    object.viewStateSubject.send(.willAppear)
                } as @convention(block) (Self, Bool) -> Void)
            }
            
            overrideImplementation(Self.self, selector: #selector(Self.viewIsAppearing(_:))) { originClass, originSelector, originIMPProvider in
                return ({ (object: Self, animated: Bool) -> Void in
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (Self, Selector, Bool) -> Void).self)
                    oriIMP(object, originSelector, animated)
                    
                    object.viewStateSubject.send(.isAppearing)
                } as @convention(block) (Self, Bool) -> Void)
            }
            
            
            overrideImplementation(Self.self, selector: #selector(Self.viewDidAppear(_:))) { originClass, originSelector, originIMPProvider in
                return ({ (object: Self, animated: Bool) -> Void in
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (Self, Selector, Bool) -> Void).self)
                    oriIMP(object, originSelector, animated)
                    
                    object.viewStateSubject.send(.didAppear)
                } as @convention(block) (Self, Bool) -> Void)
            }
            
            overrideImplementation(Self.self, selector: #selector(Self.viewWillDisappear(_:))) { originClass, originSelector, originIMPProvider in
                return ({ (object: Self, animated: Bool) -> Void in
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (Self, Selector, Bool) -> Void).self)
                    oriIMP(object, originSelector, animated)
                    
                    object.viewStateSubject.send(.willDisappear)
                } as @convention(block) (Self, Bool) -> Void)
            }
            
            overrideImplementation(Self.self, selector: #selector(Self.viewDidDisappear(_:))) { originClass, originSelector, originIMPProvider in
                return ({ (object: Self, animated: Bool) -> Void in
                    // call origin impl
                    let oriIMP = unsafeBitCast(originIMPProvider(), to: (@convention(c) (Self, Selector, Bool) -> Void).self)
                    oriIMP(object, originSelector, animated)
                    
                    object.viewStateSubject.send(.didDisappear)
                } as @convention(block) (Self, Bool) -> Void)
            }
        }
    }

}
