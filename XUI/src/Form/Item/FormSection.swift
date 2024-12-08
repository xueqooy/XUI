//
//  FormSection.swift
//  XUI
//
//  Created by xueqooy on 2024/1/11.
//

import UIKit
import XKit
import Combine

/// A container for `FormItem`,  can set its background, content insets, and item spacing, etc
/// By default, `FormSection` automatically refreshes its isHidden property based on the isHidden property of its items. If all items are hidden, the FormSection will also be hidden.
/// Conversely, if any item is visible, the `FormSection` will also be visible.
public class FormSection: FormItem {
   
    @State
    public var items: [FormItem] = [] {
        didSet {
            if !isPopulating {
                loadedSectionView?.populate {
                    items
                }
            }
            
            // Listen to the hidden attribute of items and hide the FormSection when all items are hidden
            itemObservationCancellables.removeAll()
            
            checkItems()
            
            items.forEach { item in
                item.$isHidden.didChange
                    .dropFirst() // didChange will be sent when subscription, so the first should be ignored
                    .sink { [weak self] _ in
                        guard let self = self else { return }
                        
                        self.checkItems()
                    }
                    .store(in: &itemObservationCancellables)
            }
        }
    }
    
    @EquatableState
    public var backgroundConfiguration: BackgroundConfiguration {
        didSet {
            loadedSectionView?.backgroundConfiguration = backgroundConfiguration
        }
    }
    
    @EquatableState
    public var contentInset: Insets {
        didSet {
            loadedSectionView?.contentInset = contentInset
        }
    }
    
    @EquatableState
    public var itemSpacing: CGFloat {
        didSet {
            loadedSectionView?.itemSpacing = itemSpacing
        }
    }
    
    @EquatableState
    public var automaticallyUpdatesVisibility: Bool {
        didSet {
            guard oldValue != automaticallyUpdatesVisibility else {
                return
            }
            
            checkItems()
        }
    }
    
    private var loadedSectionView: FormSectionView? {
        loadedView as? FormSectionView
    }
    
    private var isPopulating: Bool = false
    
    private var itemObservationCancellables = Set<AnyCancellable>()
        
    public init(
        items: [FormItem],
        backgroundConfiguration: BackgroundConfiguration = .init(),
        contentInset: Insets = .directionalZero,
        itemSpacing: CGFloat = 0,
        automaticallyUpdatesVisibility: Bool = true
    ) {
        self.backgroundConfiguration = backgroundConfiguration
        self.contentInset = contentInset
        self.itemSpacing = itemSpacing
        self.automaticallyUpdatesVisibility = automaticallyUpdatesVisibility
        
        super.init()
        
        defer {
            self.items = items
        }
    }
    
    public convenience init(
        backgroundConfiguration: BackgroundConfiguration = .init(),
        contentInset: Insets = .directionalZero,
        itemSpacing: CGFloat = 0,
        automaticallyUpdatesVisibility: Bool = true,
        @ArrayBuilder<FormComponent> components: () -> [FormComponent]) {
        let items = components().flatMap { $0.asFormItems() }
        
        self.init(items: items, backgroundConfiguration: backgroundConfiguration, contentInset: contentInset, itemSpacing: itemSpacing, automaticallyUpdatesVisibility: automaticallyUpdatesVisibility)
    }
    
    public func populate(keepPreviousItems: Bool = false, @ArrayBuilder<FormComponent> components: () -> [FormComponent]) {
        isPopulating = true
        defer {
            isPopulating = false
        }
        
        let items = components().flatMap { $0.asFormItems() }
        
        loadedSectionView?.populate(keepPreviousItems: keepPreviousItems) {
            items
        }
        
        if keepPreviousItems {
            self.items.append(contentsOf: items)
        } else {
            self.items = items
        }
        
        
    }
    
    override func createView() -> UIView {
        let sectionView = FormSectionView(backgroundConfiguration: backgroundConfiguration, contentInset: contentInset, itemSpacing: itemSpacing)
        
        if !items.isEmpty {
            sectionView.populate {
                items
            }
        }
        
        return sectionView
    }
    
    private func checkItems() {
        loadedSectionView?.invalidateIntrinsicContentSize()
        
        guard automaticallyUpdatesVisibility else {
            // Ignore checking the hidden attribute of items if automaticallyUpdatesVisibility is disabled
            return
        }
        
        var existsVisibleItems = false
        
        for item in items {
            if !item.isHidden {
                existsVisibleItems = true
                break
            }
        }
        
        isHidden = !existsVisibleItems
    }
}

class FormSectionView: FormView {
    
    init(backgroundConfiguration: BackgroundConfiguration, contentInset: Insets, itemSpacing: CGFloat) {
        super.init(contentScrollingBehavior: .disabled)
            
        defer {
            isEndEditingTapGestureEnabled = false
            
            self.backgroundConfiguration = backgroundConfiguration
            self.contentInset = contentInset
            self.itemSpacing = itemSpacing
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
