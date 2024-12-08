//
//  TextSelecting.swift
//  XUI
//
//  Created by xueqooy on 2023/12/28.
//

import XKit

protocol TextSelectorHost: AnyObject {
    
    var selector: TextSelector? { set get }
    
    var selectedText: String? { get set }
    
    var selectedRichText: RichText? { get set }
    
    var selectorSourceView: UIView? { get }
}


open class TextSelector: ContentPresenter {
    
    /// Set by the host
    internal weak var host: TextSelectorHost? {
        didSet {
            guard host !== oldValue else { return }
            
            oldValue?.selector = nil
            
            sourceView = host?.selectorSourceView            
        }
    }
    
    public var selectedText: String? {
        get {
            return host?.selectedText
        }
        set {
            guard let host else {
                Logs.warn("""
                    The selected text take no effect, the host is nil.
                    """)
                return
            }
            
            host.selectedText = newValue
        }
    }
    
    public var selectedRichText: RichText? {
        get {
            return host?.selectedRichText
        }
        set {
            guard let host else {
                Logs.warn("""
                    The selected rich text take no effect, the host is nil.
                    """)
                return
            }
            host.selectedRichText = newValue
        }
    }
    
    public override func activate(completion: (() -> Void)? = nil) {
        sourceView = host?.selectorSourceView
        
        super.activate(completion: completion)
    }
}
