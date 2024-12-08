//
//  OptionMenuConfiguration+Definition.swift
//  XUI
//
//  Created by xueqooy on 2024/4/8.
//

import Foundation

/**
 Support OptionMenuConfiguration using enumeration types for initialization
 
 ```
 enum LockOptions: String, OptionDefinition {
     
     case lock
     case lockAfterDueDate
     case unlock
     
     var optionImage: UIImage? {
         switch self {
         case .lock:
             UIImage(named: "lock")
             
         case .lockAfterDueDate, .unlock:
             UIImage(named: "unlock")
         }
     }
     
     var optionRichTitle: RichText? {
         switch self {
         case .lock:
             RichText.optionTitle(NSLocalizedString("Lock", comment: ""), detailText: NSLocalizedString("Students cannot take this Quiz", comment: ""))
             
         case .lockAfterDueDate:
             RichText.optionTitle(NSLocalizedString("Lock after due date", comment: ""), detailText: NSLocalizedString("Students will be unable to take this Quiz after the due date", comment: ""))
             
         case .unlock:
             RichText.optionTitle(NSLocalizedString("Unlock", comment: ""), detailText: NSLocalizedString("Students can take this Quiz", comment: ""))
         }
     }
     
     var optionType: XUI.OptionType {
         .radio
     }
 }
 
 let lockOptionGroup = OptionGroup {
     LockOptions.lock
     
     if !isOverdue {
         LockOptions.lockAfterDueDate
     }
     
     LockOptions.unlock
 }
 ```
 */
public protocol OptionDefinition {
            
    var optionId: String { get }
    
    var optionImage: UIImage? { get }
    
    var optionTitle: String? { get }
    
    var optionRichTitle: RichText? { get }
    
    var optionType: OptionType { get }
    
    var isSelectedByDefault: Bool { get }
}


public extension OptionDefinition {
        
    var optionImage: UIImage? { nil }
    
    var optionTitle: String? { nil }
    
    var optionRichTitle: RichText? { nil }
    
    var isSelectedByDefault: Bool { false }
    
    func makeOption() -> Option {
        Option(id: optionId, image: optionImage, title: optionTitle, richTitle: optionRichTitle, type: optionType, isSelected: isSelectedByDefault)
    }
}


public extension OptionDefinition where Self : RawRepresentable {
    
    var optionId: String {
        String(describing: rawValue)
    }
}


/**
 Support OptionMenuConfiguration using enumeration types for initialization
 ```
 enum Filter {
     enum ClassOption: String, OptionGroupDefinition {
         case classActivityOnly
         
         var optionTitle: String {
             "Class activity only"
         }
         
         var optionType: OptionType {
             .checkbox
         }
     }
     
     enum Timeline: String, OptionGroupDefinition {
         case assignments, polls, quizzes
         
         static var groupTitle: String? {
             "Type"
         }
         
         var optionTitle: String {
             switch self {
             case .assignments:
                 "Assignments"
             case .polls:
                 "Polls"
             case .quizzes:
                 "Quizzes"
             }
         }
         
         var optionType: OptionType {
             .radio
         }
     }
     
     enum Author: String, OptionGroupDefinition {
         case byMe, byOthers
         
         static var groupTitle: String? {
             "Author"
         }
         
         var optionTitle: String {
             switch self {
             case .byMe:
                 "By Me"
             case .byOthers:
                 "By Others"
             }
         }
         
         var optionType: OptionType {
             .radio
         }
     }
 }
 
 enum Sort: String, OptionGroupDefinition {
     case latestPosts
     case latestActivity
     
     var optionTitle: String {
         switch self {
         case .latestPosts:
             "Latest Posts"
         case .latestActivity:
             "Latest Activity"
         }
     }
     
     var optionType: OptionType {
         .radio
     }
 }
 
 private let filterConfiguration = OptionMenuConfiguration(title: "Filter") {
     Filter.ClassOption.self
     Filter.Timeline.self
     Filter.Author.self
 }
 
 private let sortConfiguration = OptionMenuConfiguration(title: "Sort", groupDefinitions: [Sort.self])
 
 ```
 */
public protocol OptionGroupDefinition: OptionDefinition, CaseIterable {
    
    static var groupTitle: String? { get }
    
    static var sortBy: ((Self, Self) -> Bool)? { get }    
}


public extension OptionGroupDefinition {
    
    static var groupTitle: String? { nil }
    
    static var sortBy: ((Self, Self) -> Bool)? { nil }
        
    static func makeGroup() -> OptionGroup {
        var cases: [Self]? = allCases as? [Self]
        
        if let sortBy {
            cases = try? cases?.sorted(by: sortBy)
        }
    
        return OptionGroup(title: groupTitle) {
            for optionDefinition in cases ?? [] {
                optionDefinition.makeOption()
            }
        }
    }
}


public extension OptionMenuConfiguration {
    
    convenience init(title: String? = nil, action: Action = [], groupDefinitions: [any OptionGroupDefinition.Type]) {
        self.init(title: title, action: action) {
            
            for groupDefinition in groupDefinitions {
                
                groupDefinition.makeGroup()
            }
        }
    }
}


public extension OptionGroup {
    
    init(title: String? = nil, optionDefinitions: [any OptionDefinition]) {
        self.init(title: title) {
            
            for optionDefinition in optionDefinitions {
                
                optionDefinition.makeOption()
            }
        }
    }
}
