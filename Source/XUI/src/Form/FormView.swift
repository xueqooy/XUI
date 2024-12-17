//
//  FormView.swift
//  XUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit
import SnapKit
import Combine

/// Similar to the vertical StackView, it supports row alignment (leading, trailing, center and fill) and row height settings.
///
/// It can automatically adjust the content offset to make the first responder visible according to the keyboard changes.
///
/// There are three ways to set item spacing in FormView:
/// 1. Set `itemSpacing` for FormView
/// 2. Add `FormSpacer`
/// 3. Call `settingCustomimSpacingAfter` of FormItem
/// Three flexible methods can be used to meet various item spacing setting requirements
///
public class FormView: UIView {
    
    public struct Constants {
        public static let defaultContentInset: Insets = .nondirectional(uniformValue: .XUI.spacing5)
        public static let defaultItemSpacing = 0.0
    }
    
    public enum ContentScrollingBehavior {
        case normal // Scrollable, the content offset will be adjusted according to the keyboard to make the content always visible.
        
        case limited // Under normal circumstances, it cannot be scrolled. The content height is less than or equal to the view height, but the content offset will be adjusted according to the keyboard to make the content always visible.
            
        case disabled // Non-scrollable, the content height is always equal to the view height.
    }

    public var backgroundConfiguration: BackgroundConfiguration {
        set {
            backgroundView.configuration = newValue
            
            setupBackgroundView()
        }
        get {
            backgroundView.configuration
        }
    }
    
    /// The display of EmptyView is automatic. When formView has no content to display (excluding Spacer), EmptyView will be displayed
    public var emptyConfiguraiton: EmptyConfiguration {
        set {
            emptyView.configuration = newValue
            
            setupEmptyView()
        }
        get {
            emptyView.configuration
        }
    }
        
    public var contentInset: Insets {
        didSet {
            container.layoutMargins = contentInset.edgeInsets(for: effectiveUserInterfaceLayoutDirection)
            invalidateIntrinsicContentSize()
        }
    }
    
    @objc dynamic public var itemSpacing: CGFloat {
        didSet {
            container.spacing = itemSpacing
            invalidateIntrinsicContentSize()
        }
    }
    
    public var items: [FormItem] {
        container.arrangedSubviews.reduce(into: [FormItem]()) { partialResult, view in
            if let item = view.formItem {
                partialResult.append(item)
            }
        }
    }
        
    open override var bounds: CGRect {
        didSet {
            guard previousBoundWidth != bounds.width else { return }
            
            previousBoundWidth = bounds.width
            invalidateIntrinsicContentSize()
        }
    }
    
    public var contentScrollingBehavior: ContentScrollingBehavior {
        didSet {
            if oldValue == contentScrollingBehavior {
                return
            }
            
            if oldValue != .disabled {
                scrollingContainer.removeFromSuperview()
            }
            container.removeFromSuperview()
            
            setupContainer()
        }
    }
    
    public private(set) lazy var scrollingContainer = FormScrollView()
    
    
    private lazy var backgroundView = BackgroundView()
    
    private lazy var emptyView = EmptyView().settingHidden(true)
    
    private let container = FormContainerStackView()

    private var didAddBackgroundView = false
    
    private var didAddEmptyView = false
    
    private var emptyViewVisibilitySubscription: AnyCancellable?
    
    private var previousBoundWidth: CGFloat?

    
    public init(contentScrollingBehavior: ContentScrollingBehavior = .normal, contentInset: Insets = Constants.defaultContentInset, itemSpacing: CGFloat = Constants.defaultItemSpacing) {
        self.contentScrollingBehavior = contentScrollingBehavior
        self.contentInset = contentInset
        self.itemSpacing = itemSpacing
        
        super.init(frame: .zero)
        
        initialize()
        setupContainer()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addItem(_ item: FormItem) {
        let loadedView = item.loadView()
        container.addArrangedSubview(loadedView)
        
        if let customSpacingAfter = item.customSpacingAfter {
            container.setCustomSpacing(customSpacingAfter, after: loadedView)
        }
        
        invalidateIntrinsicContentSize()
    }
    
    public func insertItem(_ item: FormItem, at index: Int) {
        let loadedView = item.loadView()
        container.insertArrangedSubview(loadedView, at: index)
        
        if let customSpacingAfter = item.customSpacingAfter {
            container.setCustomSpacing(customSpacingAfter, after: loadedView)
        }
        
        invalidateIntrinsicContentSize()
    }
    
    public func removeAllItems() {
        container.arrangedSubviews.forEach { $0.removeFromSuperview() }
        invalidateIntrinsicContentSize()
    }
    
    public override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        
        // Recursively invalidate content size of super form view
        if let superFormView = findSuperview(ofType: FormView.self) {
            superFormView.invalidateIntrinsicContentSize()
        }
    }
        
    public override var intrinsicContentSize: CGSize {
        // If the width is 0, the systemLayoutSizeFitting method will not work properly, so we need to use the compressed size
        if bounds.width == 0 {
            container.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        } else {
            container.systemLayoutSizeFitting(CGSize(width: bounds.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        }
    }
    
    public func updateEmptyConfiguration(_ modifier: (inout EmptyConfiguration) -> Void) {
        modifier(&emptyConfiguraiton)
    }
    
    public func updateBackgroundConfiguration(_ modifier: (inout BackgroundConfiguration) -> Void) {
        modifier(&backgroundConfiguration)
    }
    
    // MARK: - Private
    
    private func initialize() {
        container.layoutMargins = contentInset.edgeInsets(for: effectiveUserInterfaceLayoutDirection)
        container.spacing = itemSpacing
        
        isEndEditingTapGestureEnabled = true
    }
    
    private func setupContainer() {
        if contentScrollingBehavior != .disabled {
            addSubview(scrollingContainer)
            scrollingContainer.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            scrollingContainer.addSubview(container)
            container.snp.makeConstraints { make in
                make.top.bottom.left.equalToSuperview()
                make.width.equalToSuperview()
                if contentScrollingBehavior == .limited {
                    make.height.lessThanOrEqualToSuperview()
                }
            }
        } else {
            addSubview(container)
            container.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func setupEmptyView() {
        guard emptyView.superview != self else { return }
        
        addSubview(emptyView)
        
        if didAddBackgroundView {
            insertSubview(emptyView, aboveSubview: backgroundView)
        } else {
            sendSubviewToBack(emptyView)
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        didAddEmptyView = true
        
        // Tracking content changes to update empty view visibility
        container.startTrackcingContent()
        
        emptyViewVisibilitySubscription = container.$hasVisibleContent.didChange
            .sink { [weak self] hasVisibleContent in
                self?.emptyView.isHidden = hasVisibleContent ?? true
            }
    }
    
    private func setupBackgroundView() {
        guard backgroundView.superview != self else { return }

        addSubview(backgroundView)
        sendSubviewToBack(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        didAddBackgroundView = true
    }
}
