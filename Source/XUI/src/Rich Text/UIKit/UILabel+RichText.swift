//
//  UILabel+RichText.swift
//  XUI
//
//  Created by xueqooy on 2023/8/18.
//

import UIKit
import XKit

public extension UILabel {
    var richText: RichText? {
        get { touched?.0 ?? (attributedText != nil ? RichText(attributedText!) : nil) }
        set {
            if var touched = touched, touched.0.attributedString.string == newValue?.attributedString.string {
                guard let richText = newValue else {
                    self.touched = nil
                    return
                }

                // Overwrite the current highlighted attribute to the new text and replace the displayed text
                let updatedAttributedString = NSMutableAttributedString(attributedString: richText.attributedString)
                let ranges = touched.1.keys.sorted(by: { $0.length > $1.length })
                for range in ranges {
                    attributedText?.get(range).forEach { (range, attributes) in
                        updatedAttributedString.setAttributes(attributes, range: range)
                    }
                }
                attributedText = updatedAttributedString

                touched.0 = richText
                self.touched = touched
            } else {
                touched = nil
                attributedText = newValue?.attributedString
            }
            
            setupActions(for: newValue)
            setupGestureRecognizers()
        }
    }
    
    
    // Checking
    
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

    func addCheckings(_ checkings: [RichText.Checking], highlights: [RichText.Style.Action.Highlight] = .defalut, handler: @escaping (RichText.Checking.Result) -> Void) {
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
}


extension UILabel: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is EndEditingTapGestureRecognizer {
            return true
        }
        
        return false
    }
}


extension UILabel {
    private typealias Action = RichText.Style.Action
    private typealias Checking = RichText.Checking
    private typealias Highlight = Action.Highlight
    private typealias Observers = [Checking: [Checking.Action]]
    
    private struct Associations {
        static let touched = Association<(RichText, [NSRange: [Action]])>()
        static var actions = Association<[NSRange: [Action]]>()
        static var observers = Association<Observers>()
        static var gestures = Association<[UIGestureRecognizer]>()
    }

    private var isActionEnabled: Bool {
        return !actions.isEmpty
    }

    private var gestures: [UIGestureRecognizer] {
        get { Associations.gestures[self] ?? [] }
        set { Associations.gestures[self] = newValue }
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
        get { Associations.observers[self] ?? [:] }
        set { Associations.observers[self] = newValue }
    }
    
    private func setupActions(for richText: RichText?) {
        actions = [:]

        guard let richText = richText else {
            return
        }
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
            guard let touched = self.touched else { return }

            self.touched = nil
            
            guard self.isActionEnabled else { return }
            
            
            let actions = touched.1.flatMap({ $0.value })
            for action in actions where action.trigger.matching(sender) {
                action.internalHandler?()
            }
        }
    }

    private func matching(_ point: CGPoint) -> [NSRange: [Action]] {
        let text = adapt(scaledAttributedText ?? synthesizedAttributedText ?? attributedText, with: numberOfLines)
        guard let text = text else { return [:] }
        let richText = RichText(text)
        
        // Building a TextKit for Synchronous Labels
        let delegate =  RichText.UILabelLayoutManagerDelegate(scaledMetrics: scaledMetrics, baselineAdjustment: baselineAdjustment)
        let textStorage = NSTextStorage()
        let textContainer = NSTextContainer(size: bounds.size)
        let layoutManager = NSLayoutManager()
        layoutManager.delegate = delegate
        textContainer.lineBreakMode = lineBreakMode
        textContainer.lineFragmentPadding = 0.0
        textContainer.maximumNumberOfLines = numberOfLines
        layoutManager.usesFontLeading = false
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textStorage.setAttributedString(richText.attributedString)

        layoutManager.ensureLayout(for: textContainer)

        let height = layoutManager.usedRect(for: textContainer).height

        var point = point
        point.y -= (bounds.height - height) / 2

        // Debug
//        subviews.filter({ $0 is DebugView }).forEach({ $0.removeFromSuperview() })
//        let view = DebugView(frame: .init(x: 0, y: (bounds.height - height) / 2, width: bounds.width, height: height))
//        view.draw = { layoutManager.drawGlyphs(forGlyphRange: .init(location: 0, length: textStorage.length), at: .zero) }
//        addSubview(view)

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

    private func adapt(_ string: NSAttributedString?, with numberOfLines: Int) -> NSAttributedString? {
        /**
         Due to the inconsistent behavior of lineBreakMode in rich text for UILabel and TextKit, the default. byTruncatingTail of UILabel cannot be displayed correctly in TextKit
         So replace all lineBreakMode in rich text with TextKit's default. byWordWrapping to solve the problem of multi line display and inconsistency
         Note: After testing, when the maximum number of lines is 1, the line wrapping mode performs the same as byCharWrapping
        */
        guard let string = string else {
            return nil
        }

        let mutable = NSMutableAttributedString(attributedString: string)
        mutable.enumerateAttribute(
            .paragraphStyle,
            in: .init(location: 0, length: mutable.length),
            options: .longestEffectiveRangeNotRequired
        ) { (value, range, stop) in
            guard let old = value as? NSParagraphStyle else { return }
            guard let new = old.mutableCopy() as? NSMutableParagraphStyle else { return }
            new.lineBreakMode = numberOfLines == 1 ? .byCharWrapping : .byWordWrapping
            if #available(iOS 11.0, *) {
                new.setValue(1, forKey: "lineBreakStrategy")
            }
            mutable.addAttribute(.paragraphStyle, value: new, range: range)
        }
        return mutable
    }
    
    
    // Touch
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            isActionEnabled,
            let richText = richText,
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
//            self.touched = nil
            self.attributedText = touched.0.attributedString
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
        }
    }
}


private class DebugView: UIView {
    var draw: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2983732877)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.draw?()
    }
}
