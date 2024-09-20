//
//  RichText+StyleModifier.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/23.
//

import Foundation

public extension RichText {
    
    mutating func addStyles(_ styles: Style..., range: NSRange? = nil) {
        addStyles(styles, range: range)
    }
    
    mutating func addStyles(_ styles: [Style], range: NSRange? = nil) {
        let range = range ?? .init(location: 0, length: length)
        guard !styles.isEmpty, range.length > 0 else { return }
        
        let styles = styles.mergingActions()
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        styles.forEach {
            attributes.merge($0.attributes, uniquingKeysWith: { $1 })
        }
        
        let attributedString = NSMutableAttributedString(attributedString: attributedString)
        attributedString.addAttributes(attributes, range: range)
        self.attributedString = attributedString
    }
    
    mutating func addStyles(_ styles: Style..., checkings: [Checking]) {
        addStyles(styles, checkings: checkings)
    }
    
    mutating func addStyles(_ styles: [Style], checkings: [Checking]) {
        guard !styles.isEmpty, !checkings.isEmpty else { return }
        
        let styles = styles.mergingActions()
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        styles.forEach { attributes.merge($0.attributes, uniquingKeysWith: { $1 }) }
        
        let matched = matching(checkings)
        let attributedString = NSMutableAttributedString(attributedString: attributedString)
        matched.forEach { attributedString.addAttributes(attributes, range: $0.0) }
        self.attributedString = attributedString
    }
    
    mutating func setStyles(_ styles: Style..., range: NSRange? = nil) {
        setStyles(styles, range: range)
    }
    
    mutating func setStyles(_ styles: [Style]?, range: NSRange? = nil) {
        let range = range ?? .init(location: 0, length: length)
        guard range.length > 0 else { return }
                
        var attributes: [NSAttributedString.Key: Any]?
        if var styles = styles {
            styles = styles.mergingActions()
            
            attributes = [:]
            styles.forEach {
                attributes!.merge($0.attributes, uniquingKeysWith: { $1 })
            }
        }
        
        let attributedString = NSMutableAttributedString(attributedString: attributedString)
        attributedString.setAttributes(attributes, range: range)
        self.attributedString = attributedString
    }
    
    mutating func setStyles(_ styles: Style..., checkings: [Checking]) {
        setStyles(styles, checkings: checkings)
    }
    
    mutating func setStyles(_ styles: [Style]?, checkings: [Checking]) {
        guard !checkings.isEmpty else { return }
                
        var attributes: [NSAttributedString.Key: Any]?
        if var styles = styles {
            styles = styles.mergingActions()
            
            attributes = [:]
            styles.forEach {
                attributes!.merge($0.attributes, uniquingKeysWith: { $1 })
            }
        }
        
        let matched = matching(checkings)
        let attributedString = NSMutableAttributedString(attributedString: attributedString)
        matched.forEach { attributedString.setAttributes(attributes, range: $0.0) }
        self.attributedString = attributedString
    }
    
    func addingStyles(_ styles: Style..., range: NSRange? = nil) -> Self {
        addingStyles(styles, range: range)
    }
    
    func addingStyles(_ styles: [Style], range: NSRange? = nil) -> Self {
        var richText = self
        richText.addStyles(styles, range: range)
        return richText
    }
    
    func addingStyles(_ styles: Style..., checkings: [Checking]) -> Self {
        addingStyles(styles, checkings: checkings)
    }
    
    func addingStyles(_ styles: [Style], checkings: [Checking]) -> Self {
        var richText = self
        richText.addStyles(styles, checkings: checkings)
        return richText
    }
    
    func settingStyles(_ styles: Style..., range: NSRange? = nil) -> Self {
        settingStyles(styles, range: range)
    }
    
    func settingStyles(_ styles: [Style]?, range: NSRange? = nil) -> Self {
        var richText = self
        richText.setStyles(styles, range: range)
        return richText
    }
    
    func settingStyles(_ styles: Style..., checkings: [Checking]) -> Self {
        settingStyles(styles, checkings: checkings)
    }
    
    func settingStyles(_ styles: [Style]?, checkings: [Checking]) -> Self {
        var richText = self
        richText.setStyles(styles, checkings: checkings)
        return richText
    }
}
