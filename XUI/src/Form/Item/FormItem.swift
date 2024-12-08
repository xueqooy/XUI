//
//  FormItem.swift
//  XUI
//
//  Created by xueqooy on 2023/3/5.
//

import UIKit
import XKit

/// Abstract class
public class FormItem: StateObservableObject {
        
    @EquatableState
    public var customSpacingAfter: CGFloat? {
        didSet {
            guard oldValue != customSpacingAfter else {
                return
            }
            
            guard let loadedView = loadedView, let stackView = loadedView.superview as? UIStackView else {
                return
            }
            
            if let customSpacingAfter = customSpacingAfter {
                stackView.setCustomSpacing(customSpacingAfter, after: loadedView)
            } else {
                stackView.setCustomSpacing(UIStackView.spacingUseDefault, after: loadedView)
            }
        }
    }
     
    @EquatableState
    public var isHidden: Bool = false {
        didSet {
            guard oldValue != isHidden else {
                return
            }
            
            loadedView?.isHidden = isHidden
            loadedView?.findSuperview(ofType: FormView.self)?.invalidateIntrinsicContentSize()
        }
    }
    
    public func removeFromForm() {
        guard let loadedView else { return }
        
        let superFormView = loadedView.findSuperview(ofType: FormView.self)
        
        loadedView.removeFromSuperview()
        
        superFormView?.invalidateIntrinsicContentSize()
    }
    
    
    // MARK: - Internal Invoke
    
    weak var loadedView: UIView?
    
    func loadView() -> UIView  {
        loadedView?.removeFromSuperview()
        loadedView?.formItem = nil
        
        let view = createView()
        view.formItem = self
        view.isHidden = isHidden
        
        loadedView = view
        
        return view
    }
    
    // MARK: - Subclass Override
    
    func createView() -> UIView {
        preconditionFailure("Subclass should override this method")
    }
}


// MARK: - UIView+FormItem

private let formItemAssociation = Association<FormItem>()

extension UIView {
    var formItem: FormItem? {
        get { formItemAssociation[self] }
        set { formItemAssociation[self] = newValue }
    }
}


extension FormItem: Then { }
