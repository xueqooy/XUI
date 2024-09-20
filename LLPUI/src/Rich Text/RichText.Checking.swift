//
//  RichText.Checking.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/18.
//

import Foundation

public extension RichText {
    enum Checking: Hashable {
        public enum Result {
            case range(NSAttributedString)
            case regex(NSAttributedString)
            case action([RichText.Style.Action])
            case attachment(NSTextAttachment)
            case date(Date)
            case link(URL)
            case address(Address)
            case phoneNumber(String)
            case transitInformation(TransitInformation)
        }
        
        case range(NSRange)
        case regex(String)
        case action
        case attachment
        case date
        case link
        case address
        case phoneNumber
        case transitInformation
    }
}

public extension RichText.Checking {
    struct Action {
        public typealias Trigger = RichText.Style.Action.Trigger
        public typealias Highlight = RichText.Style.Action.Highlight
        
        let trigger: Trigger
        let highlights: [Highlight]
        let handler: (Result) -> Void
        
        public init(_ trigger: Trigger = .tap, highlights: [Highlight] = .defalut, handler: @escaping (Result) -> Void) {
            self.trigger = trigger
            self.highlights = highlights
            self.handler = handler
        }
    }
}

public extension RichText.Checking.Result {
    struct Date {
        let date: Foundation.Date?
        let duration: TimeInterval
        let timeZone: TimeZone?
    }
    
    struct Address {
        let name: String?
        let jobTitle: String?
        let organization: String?
        let street: String?
        let city: String?
        let state: String?
        let zip: String?
        let country: String?
        let phone: String?
    }
    
    struct TransitInformation {
        let airline: String?
        let flight: String?
    }
}

public extension RichText {
    
    func matching(_ checkings: [Checking]) -> [NSRange: (Checking, Checking.Result)] {
        guard !checkings.isEmpty else {
            return [:]
        }
        
        let checkings = checkings.filtered(duplication: \.self).sorted { $0.order < $1.order }
        var result: [NSRange: (Checking, Checking.Result)] = [:]
        
        func contains(_ range: NSRange) -> Bool {
            guard !result.keys.isEmpty else {
                return false
            }
            guard result[range] != nil else {
                return false
            }
            return result.keys.contains(where: { $0.overlap(range) })
        }
        
        checkings.forEach { (checking) in
            switch checking {
            case .range(let range) where !contains(range):
                let substring = attributedString.attributedSubstring(from: range)
                result[range] = (checking, .range(substring))
                
            case .regex(let string):
                guard let regex = try? NSRegularExpression(pattern: string, options: .caseInsensitive) else { return }
                
                let matches = regex.matches(
                    in: attributedString.string,
                    options: .init(),
                    range: .init(location: 0, length: attributedString.length)
                )
                
                for match in matches where !contains(match.range) {
                    let substring = attributedString.attributedSubstring(from: match.range)
                    result[match.range] = (checking, .regex(substring))
                }
                
            case .action:
                let ranges: [NSRange: [Style.Action]] = attributedString.get(.action)
                for range in ranges where !contains(range.key) {
                    let actions = range.value.filter({ $0.isExternal })
                    result[range.key] = (.action, .action(actions))
                }

            case .attachment:
                let attachments: [NSRange: NSTextAttachment] = attributedString.get(.attachment)
                func allow(_ range: NSRange, _ attachment: NSTextAttachment) -> Bool {
                    return !contains(range) && !((attachment as? TextAttachment)?.view != nil)
                }
                for attachment in attachments where allow(attachment.key, attachment.value) {
                    result[attachment.key] = (.attachment, .attachment(attachment.value))
                }
            
            case .link:
                let links: [NSRange: URL] = attributedString.get(.link)
                for link in links where !contains(link.key) {
                    result[link.key] = (.link, .link(link.value))
                }
                fallthrough
                
            case .date, .address, .phoneNumber, .transitInformation:
                guard let detector = try? NSDataDetector(types: NSTextCheckingAllTypes) else { return }
                
                let matches = detector.matches(
                    in: attributedString.string,
                    options: .init(),
                    range: .init(location: 0, length: attributedString.length)
                )
                
                for match in matches where !contains(match.range) {
                    guard let type = match.resultType.map() else { continue }
                    guard checkings.contains(type) else { continue }
                    guard let mapped = match.map() else { continue }
                    result[match.range] = (type, mapped)
                }
                
            default:
                break
            }
        }
        
        return result
    }
}

fileprivate extension RichText.Checking {
    var order: Int {
        switch self {
        case .range:    return 0
        case .regex:    return 1
        case .action:   return 2
        default:        return 3
        }
    }
}

fileprivate extension RichText.Checking {
    func map() -> NSTextCheckingResult.CheckingType? {
        switch self {
        case .date:
            return .date
        
        case .link:
            return .link
        
        case .address:
            return .address
            
        case .phoneNumber:
            return .phoneNumber
            
        case .transitInformation:
            return .transitInformation
            
        default:
            return nil
        }
    }
}

fileprivate extension NSTextCheckingResult.CheckingType {
    func map() -> RichText.Checking? {
        switch self {
        case .date:
            return .date
        
        case .link:
            return .link
        
        case .address:
            return .address
            
        case .phoneNumber:
            return .phoneNumber
            
        case .transitInformation:
            return .transitInformation
            
        default:
            return nil
        }
    }
}

fileprivate extension NSTextCheckingResult {
    func map() -> RichText.Checking.Result? {
        switch resultType {
        case .date:
            return .date(
                .init(
                    date: date,
                    duration: duration,
                    timeZone: timeZone
                )
            )
        
        case .link:
            guard let url = url else { return nil }
            return .link(url)
        
        case .address:
            guard let components = addressComponents else { return nil }
            return .address(
                .init(
                    name: components[.name],
                    jobTitle: components[.jobTitle],
                    organization: components[.organization],
                    street: components[.street],
                    city: components[.city],
                    state: components[.state],
                    zip: components[.zip],
                    country: components[.country],
                    phone: components[.phone]
                )
            )
            
        case .phoneNumber:
            guard let number = phoneNumber else { return nil }
            return .phoneNumber(number)
            
        case .transitInformation:
            guard let components = components else { return nil }
            return .transitInformation(
                .init(
                    airline: components[.airline],
                    flight: components[.flight]
                )
            )
            
        default:
            return nil
        }
    }
}

fileprivate extension NSRange {
    func overlap(_ other: NSRange) -> Bool {
        guard
            let lhs = Range(self),
            let rhs = Range(other) else {
            return false
        }
        return lhs.overlaps(rhs)
    }
}

fileprivate extension Array {
    func filtered<E: Equatable>(duplication path: KeyPath<Element, E>) -> [Element] {
        return reduce(into: [Element]()) { (result, e) in
            let contains = result.contains { $0[keyPath: path] == e[keyPath: path] }
            result += contains ? [] : [e]
        }
    }
}
    
