//
//  OptionsObject.swift
//  CombineCocoa
//
//  Created by xueqooy on 2024/4/7.
//

import Foundation
import XKit
import Combine

public enum OptionType: Equatable {
    case checkbox
    case checkmark
    case radio // Only one radio in a group can be selected
    case `switch`
    
    static let singleSelectionTypes: [OptionType] = [.radio]
    
    var isSingleSelection: Bool {
        Self.singleSelectionTypes.contains(self)
    }
}


public struct Option: Equatable {

    public let id: String
    
    public let image: UIImage?
    
    public let title: String?
    
    /// if title and richTitle are both set, richTitle will be used
    public let richTitle: RichText?

    public let type: OptionType
    
    /// Indicates whether currently selected
    public var isSelected: Bool
    
    /// Indicates whether it should be selected after reset
    public let isSelectedByDefault: Bool
    
    public init(id: String, image: UIImage? = nil, title: String? = nil, richTitle: RichText? = nil, type: OptionType, isSelected: Bool = false) {
        self.id = id
        self.type = type
        self.image = image
        self.title = title
        self.richTitle = richTitle
        self.isSelected = isSelected
        self.isSelectedByDefault = isSelected
    }
    
    public init(id: String, image: UIImage? = nil, title: String? = nil, richTitle: RichText? = nil, type: OptionType, isSelected: Bool, isSelectedByDefault: Bool) {
        self.id = id
        self.type = type
        self.image = image
        self.title = title
        self.richTitle = richTitle
        self.isSelected = isSelected
        self.isSelectedByDefault = isSelectedByDefault
    }
    
    public mutating func reset() {
        isSelected = isSelectedByDefault
    }
}


public struct OptionGroup: Equatable {
            
    public let title: String?
    
    public private(set) var options: [Option] {
        didSet {
            checkOptions()
        }
    }
    
    public var numberOfChanges: Int {
        var countedSingleSelectionType = Set<OptionType>()
        
        return options.reduce(into: 0) { partialResult, option in
            guard option.isSelected != option.isSelectedByDefault else {
                return
            }
            
            let optionType = option.type
            
            if optionType.isSingleSelection {
                if !countedSingleSelectionType.contains(optionType) {
                    countedSingleSelectionType.insert(optionType)
                    partialResult += 1
                }
            } else {
                partialResult += 1
            }
        }
    }
        
    public init(title: String? = nil, options: [Option]) {
        self.title = title
        self.options = options
        
        checkOptions()
    }
    
    public func option(for id: String) -> Option? {
        options.first { $0.id == id }
    }
    
    public mutating func updateSelected(_ selected: Bool, forOptionAt index: Int) {
        let targetOptionType = options[index].type
        if selected && targetOptionType.isSingleSelection {
            var updatedOptions = options
            
            for (curIndex, option) in updatedOptions.enumerated() {
                guard option.type == targetOptionType else {
                    continue
                }
                
                updatedOptions[curIndex].isSelected = curIndex == index
            }
            
            options = updatedOptions
            return
        }
            
        options[index].isSelected = selected
    }
    
    @discardableResult
    public mutating func updateSelected(_ selected: Bool, forOptionWithId id: String) -> Bool {
        guard let index = options.firstIndex(where: { $0.id == id }) else { return false }
        
        updateSelected(selected, forOptionAt: index)
        return true
    }
    
    public mutating func reset() {
        var updatedOptions = options
                
        for i in 0..<updatedOptions.count {
            updatedOptions[i].reset()
        }
        
        options = updatedOptions
    }
    
    private mutating func checkOptions() {
        // Check Duplicates
        let ids = options.map(\.id)
        
        precondition(Set(ids).count == ids.count, "Duplicate ids exist")

        // Check single selection state
        var selectedSingleSelectionTypes = Set<OptionType>()
        var selectedSingleSelectionTypesByDefault = Set<OptionType>()
        
        for option in options.reversed() {
            guard option.type.isSingleSelection else {
                continue
            }
            
            if option.isSelectedByDefault {
                if selectedSingleSelectionTypesByDefault.contains(option.type) {
                    preconditionFailure("There are multiple selections by default for the radio in a group")
                } else {
                    selectedSingleSelectionTypesByDefault.insert(option.type)
                }
            }
            
            if option.isSelected {
                // Only one radio in a group can be selected
                if selectedSingleSelectionTypes.contains(option.type) {
                    preconditionFailure("There are multiple selections for the radio in a group")
                } else {
                    selectedSingleSelectionTypes.insert(option.type)
                }
            }
        }
    }
}


public class OptionMenuConfiguration: StateObservableObject {
    
    public struct Action: OptionSet {
        
        public var rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static let clear = Action(rawValue: 1)
        public static let apply = Action(rawValue: 1 << 1)
        
        public static let all: Action = [.clear, .apply]
    }
        
    public let title: String?
        
    public let action: Action
    
    public var numberOfChanges: Int {
        groups.reduce(into: 0) { partialResult, group in
            partialResult += group.numberOfChanges
        }
    }
    
    public var changed: ((OptionMenuConfiguration) -> Void)? {
        didSet {
            if changed != nil {
                subscription = stateDidChange
                    .sink { [weak self] _ in
                        guard let self else { return }
                        
                        self.changed?(self)
                    }
            } else {
                subscription = nil
            }
            
        }
    }
    
    @EquatableState
    public internal(set) var groups: [OptionGroup] {
        didSet {
            checkGroups()
        }
    }
    
    private var subscription: AnyCancellable?

    public init(title: String? = nil, action: Action = [], groups: [OptionGroup]) {
        self.title = title
        self.groups = groups
        self.action = action
        
        checkGroups()
    }
    
    public func option(for id: String) -> Option? {
        groups.lazy
            .flatMap { $0.options }
            .first { $0.id == id }
    }
    
    @discardableResult
    public func updateSelected(_ selected: Bool, forOptionWithId id: String) -> Bool {
        var optionIndex: Int?
        guard let groupIndex = groups.firstIndex(where: {
            if let i = $0.options.firstIndex(where: { $0.id == id }) {
                optionIndex = i
                return true
            }
            
            return false
        }), let optionIndex else {
             return false
        }
        
        
        groups[groupIndex].updateSelected(selected, forOptionAt: optionIndex)
        
        return true
    }
    
    private func checkGroups() {
        let ids = groups.flatMap {
            $0.options.map(\.id)
        }
        
        precondition(Set(ids).count == ids.count, "Duplicate ids exist")
    }
}


extension OptionMenuConfiguration: CustomStringConvertible {
    
    public var description: String {
        var result: String = ""
        for group in self.groups {
            result += "-- \(group.title ?? "") --\n"
            for option in group.options {
                result += "[\(option.id)][\(option.isSelectedByDefault)] \(option.richTitle?.attributedString.string ?? option.title ?? "nil") -> \(option.isSelected)\n"
            }
        }
        return result
    }
}
