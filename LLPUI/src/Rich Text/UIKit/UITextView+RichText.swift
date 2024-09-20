//
//  UITextView+RichText.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/20.
//

import UIKit
import LLPUtils

public extension UITextView {
    
    var richText: RichText! {
        get { touched?.0 ?? RichText(attributedText) }
        set {
            let newValue = newValue ?? .init("")
            
            if var touched = touched, touched.0.attributedString.string == newValue.attributedString.string {
                touched.0 = newValue
                self.touched = touched
                
                // Overwrite the current highlighted attribute to the new text and replace the displayed text
                let updatedAttributedString = NSMutableAttributedString(attributedString: newValue.attributedString)
                let ranges = touched.1.keys.sorted(by: { $0.length > $1.length })
                for range in ranges {
                    attributedText?.get(range).forEach { (range, attributes) in
                        updatedAttributedString.setAttributes(attributes, range: range)
                    }
                }
                attributedText = updatedAttributedString
                
            } else {
                touched = nil
                attributedText = newValue.attributedString
            }
            
            setupActions(for: newValue)
            setupViewAttachments(for: newValue)
            setupGestureRecognizers()
        }
    }
    
    func addChecking(_ checking: RichText.Checking, action: RichText.Checking.Action) {
        var observers = observers
        if var actions = observers[checking] {
            actions.append(action)
            observers[checking] = actions
            
        } else {
            observers[checking] = [action]
        }
        self.observers = observers
    }
    
    func addChecking(_ checking: RichText.Checking, highlights: [RichText.Checking.Action.Highlight] = .defalut, handler: @escaping (RichText.Checking.Result) -> Void) {
        addChecking(checking, action: .init(.tap, highlights: highlights, handler: handler))
    }
    
    func addCheckings(_ checkings: [RichText.Checking], highlights: [RichText.Checking.Action.Highlight] = .defalut, handler: @escaping (RichText.Checking.Result) -> Void) {
        checkings.forEach {
            addChecking($0, highlights: highlights, handler: handler)
        }
    }
    
    func removeChecking(_ checking: RichText.Checking) {
        observers.removeValue(forKey: checking)
    }
  
    func removeCheckings(_ checkings: [RichText.Checking]) {
        checkings.forEach { observers.removeValue(forKey: $0) }
    }
    
    func layoutViewAttachmentsIfNeeded() {
        _layoutViewAttachmentsIfNeeded()
    }
}


extension UITextView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is EndEditingTapGestureRecognizer {
            return true
        }
        
        return false
    }
}


extension UITextView {
    private typealias Action = RichText.Style.Action
    private typealias Checking = RichText.Checking
    private typealias Highlight = Action.Highlight
    private typealias Observers = [Checking: [Checking.Action]]
    
    private struct Associations {
        static let gestures = Association<[UIGestureRecognizer]>()
        static let observations = Association<[String: NSKeyValueObservation]>()
        static let touched = Association<(RichText, [NSRange: [Action]])>()
        static let actions = Association<[NSRange: [Action]]>()
        static let observers = Association<Observers>()
        static let viewAttachmentContainerViews = Association<[NSRange: ViewAttachmentContainerView]>()
    }
    
    fileprivate var isActionEnabled: Bool {
        return !actions.isEmpty && (!isEditable && !isSelectable)
    }
    
    private var gestures: [UIGestureRecognizer] {
        get { Associations.gestures[self] ?? [] }
        set { Associations.gestures[self] = newValue }
    }
    
    private var observations: [String: NSKeyValueObservation] {
        get { Associations.observations[self]  ?? [:] }
        set { Associations.observations[self] = newValue }
    }
    
    private var touched: (RichText, [NSRange: [Action]])? {
        get { Associations.touched[self] }
        set { Associations.touched[self] = newValue }
    }

    private var actions: [NSRange: [Action]] {
        get { Associations.actions[self] ?? [:] }
        set { Associations.actions[self] = newValue }
    }

    private var observers: Observers {
        get { Associations.observers[self]  ?? [:] }
        set { Associations.observers[self] = newValue }
    }
    
    private var viewAttachmentContainerViews: [NSRange: ViewAttachmentContainerView] {
        get { Associations.viewAttachmentContainerViews[self] ?? [:] }
        set { Associations.viewAttachmentContainerViews[self] = newValue }
    }
    
    private func setupActions(for richText: RichText) {
        // Get current actions
        actions = richText.attributedString.get(.action)
        // Add actions based on checking
        let observers = observers
        richText.matching(.init(observers.keys)).forEach { (range, checking) in
            let (type, result) = checking
            if var actionsInRange = actions[range] {
                for action in observers[type] ?? [] {
                    var internalAction = Action(action.trigger, highlights: action.highlights) { _ in
                        action.handler(result)
                    }
                    internalAction.isExternal = false
                    actionsInRange.append(internalAction)
                }
                actions[range] = actionsInRange
            } else {
                actions[range] = observers[type]?.map { action in
                    var internalAction = Action(action.trigger, highlights: action.highlights) { _ in
                        action.handler(result)
                    }
                    internalAction.isExternal = false
                    return internalAction
                }
            }
        }
        
        // Add internal handler for actions
        actions = actions.reduce(into: [:]) {
            let target: Action.Target = richText.attributedString.get($1.key)
            let actions: [Action] = $1.value.reduce(into: []) {
                var action = $1
                action.internalHandler = {
                    action.handler(target)
                }
                $0.append(action)
            }
            $0[$1.key] = actions
        }
    }
    
    private func setupGestureRecognizers() {
        delaysContentTouches = false
        
        gestures.forEach { removeGestureRecognizer($0) }
        gestures = []
        
        let triggers = actions.values.flatMap({ $0 }).map({ $0.trigger })
        Set(triggers).forEach {
            switch $0 {
            case .tap:
                let gesture = UITapGestureRecognizer(target: self, action: #selector(Self.gestureAction(_:)))
                gesture.cancelsTouchesInView = false
                gesture.delegate = self
                addGestureRecognizer(gesture)
                gestures.append(gesture)
                
            case .longPress:
                let gesture = UILongPressGestureRecognizer(target: self, action: #selector(Self.gestureAction(_:)))
                gesture.cancelsTouchesInView = false
                addGestureRecognizer(gesture)
                gestures.append(gesture)
            }
        }
    }
    
    @objc private func gestureAction(_ sender: UIGestureRecognizer) {
        guard sender.state == .ended else { return }
        RichText.ActionQueue.main.action { [weak self] in
            guard let self = self else { return }
            guard self.isActionEnabled else { return }
            guard let touched = self.touched else { return }
            let actions = touched.1.flatMap({ $0.value })
            for action in actions where action.trigger.matching(sender) {
                action.internalHandler?()
            }
        }
    }
    
    private func setupViewAttachments(for richText: RichText) {
        observations = [:]
        
        for view in subviews where view is ViewAttachmentContainerView {
            view.removeFromSuperview()
        }
        viewAttachmentContainerViews = [:]
        
        let viewAttachments: [NSRange: RichText.TextAttachment] = richText.attributedString.get(.attachment).filter { $0.value.view != nil}
        
        guard !viewAttachments.isEmpty else {
            return
        }
        
        viewAttachments.forEach {
            let view = ViewAttachmentContainerView($0.value.view!, layout: $0.value.layout)
            addSubview(view)
            viewAttachmentContainerViews[$0.key] = view
        }
        
        _layoutViewAttachmentsIfNeeded()
        
        observations["bounds"] = observe(\.bounds, options: [.new, .old]) { (object, changed) in
            object._layoutViewAttachmentsIfNeeded(true)
        }
        observations["frame"] = observe(\.frame, options: [.new, .old]) { (object, changed) in
            guard changed.newValue?.size != changed.oldValue?.size else { return }
            object._layoutViewAttachmentsIfNeeded()
        }
    }
    
    func _layoutViewAttachmentsIfNeeded(_ isVisible: Bool = false) {
        guard !viewAttachmentContainerViews.isEmpty else {
            return
        }
        
        func update(_ range: NSRange, _ view: ViewAttachmentContainerView) {
            view.isHidden = false
            let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            
            let attachmentSize = layoutManager.attachmentSize(forGlyphAt: glyphRange.location)
            let lineFragRect = layoutManager.lineFragmentRect(forGlyphAt: glyphRange.location, effectiveRange: nil)
                                                              
            let glyphLocation = layoutManager.location(forGlyphAt: glyphRange.location)
            
            let attachmentRect = CGRect(origin: .init(x: lineFragRect.minX + glyphLocation.x, y: lineFragRect.minY + glyphLocation.y - attachmentSize.height), size: attachmentSize)
                .offsetBy(dx: textContainerInset.left, dy: textContainerInset.top)

            view.frame = attachmentRect
        }
        
        if isVisible {
            let offset = CGPoint(x: contentOffset.x - textContainerInset.left, y: contentOffset.y - textContainerInset.top)
            let visible = layoutManager.glyphRange(forBoundingRect: .init(origin: offset, size: bounds.size), in: textContainer)
            for (range, view) in viewAttachmentContainerViews {
                if visible.contains(range.location) {
                    layoutManager.ensureLayout(forCharacterRange: range)
                    update(range, view)
                } else {
                    view.isHidden = true
                }
            }
            
        } else {
            layoutIfNeeded()
            layoutManager.invalidateLayout(
                forCharacterRange: .init(location: 0, length: textStorage.length),
                actualCharacterRange: nil
            )
            layoutManager.ensureLayout(for: textContainer)

            viewAttachmentContainerViews.forEach(update)
        }
    }
    
    private func matching(_ point: CGPoint) -> [NSRange: [Action]] {
        layoutManager.ensureLayout(for: textContainer)
        
        var point = point
        point.x -= textContainerInset.left
        point.y -= textContainerInset.top
        /**
        // Debug
        subviews.filter({ $0 is DebugView }).forEach({ $0.removeFromSuperview() })
        let height = layoutManager.usedRect(for: textContainer).height
        let view = DebugView(frame: .init(x: textContainerInset.left, y: textContainerInset.top, width: bounds.width, height: height))
        view.draw = { self.layoutManager.drawGlyphs(forGlyphRange: .init(location: 0, length: self.textStorage.length), at: .zero) }
        addSubview(view)
        */
        var fraction: CGFloat = 0
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer, fractionOfDistanceThroughGlyph: &fraction)
        let index = layoutManager.characterIndexForGlyph(at: glyphIndex)
        guard fraction > 0, fraction < 1 else {
            return [:]
        }
        let ranges = actions.keys.filter({ $0.contains(index) })
        return ranges.reduce(into: [:]) {
            $0[$1] = actions[$1]
        }
    }
    
    // Touch
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            isActionEnabled,
            let touch = touches.first else {
            super.touchesBegan(touches, with: event)
            return
        }
        let results = matching(touch.location(in: self))
        guard !results.isEmpty else {
            super.touchesBegan(touches, with: event)
            return
        }
        RichText.ActionQueue.main.began {
            let richText = self.richText!
            touched = (richText, results)

            let ranges = results.keys.sorted(by: { $0.length > $1.length })
            for range in ranges {
                var temp: [NSAttributedString.Key: Any] = [:]
                results[range]?.first?.highlights.forEach {
                    temp.merge($0.attributes, uniquingKeysWith: { $1 })
                }
                attributedText = richText.attributedString.reset(range: range) { (attributes) in
                    attributes.merge(temp, uniquingKeysWith: { $1 })
                }
            }
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            isActionEnabled,
            let touched = self.touched else {
            super.touchesEnded(touches, with: event)
            return
        }
        
        RichText.ActionQueue.main.ended {
            self.touched = nil
            self.attributedText = touched.0.attributedString
            self._layoutViewAttachmentsIfNeeded()
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            isActionEnabled,
            let touched = self.touched else {
            super.touchesCancelled(touches, with: event)
            return
        }

        RichText.ActionQueue.main.cancelled {
            self.touched = nil
            self.attributedText = touched.0.attributedString
            self._layoutViewAttachmentsIfNeeded()
        }
    }
}

    
class ViewAttachmentContainerView: UIView {
    typealias Layout = RichText.Attachment.Layout
    
    let view: UIView
    let layout: Layout
        
    init(_ view: UIView, layout: Layout) {
        self.view = view
        self.layout = layout
        
        super.init(frame: .zero)
        
        clipsToBounds = true
        backgroundColor = .clear
                
        addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        view.frame = bounds
    }
}
