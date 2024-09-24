//
//  OptionMenuDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2024/4/7.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI

class OptionMenuDemoController: DemoController {
    
    enum Filter {
        enum ClassOption: String, OptionGroupDefinition {
            case classActivityOnly
            
            var optionTitle: String? {
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
            
            var optionTitle: String? {
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
            
            var optionTitle: String? {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel(text: "What’s On", textColor: Colors.title, font: Fonts.h6)
        let flexibleSpacer = SpacerView.flexible()
        let actionView = FilterSortActionView()
        
        filterConfiguration.stateDidChange.sink { [weak self] in
            guard let self else { return }
            
            actionView.filterBadgeNumber = self.filterConfiguration.numberOfChanges
            
            print(Filter.ClassOption.allCases.map { "\($0.rawValue) -> \(self.filterConfiguration.option(for: $0.rawValue)?.isSelected ?? false)" }.joined(separator: "\n"))
            print(Filter.Timeline.allCases.map { "\($0.rawValue) -> \(self.filterConfiguration.option(for: $0.rawValue)?.isSelected ?? false)" }.joined(separator: "\n"))
            print(Filter.Author.allCases.map { "\($0.rawValue) -> \(self.filterConfiguration.option(for: $0.rawValue)?.isSelected ?? false)" }.joined(separator: "\n"))
        }
        .store(in: &cancellables)
        
        sortConfiguration.stateDidChange.sink { [weak self] in
            guard let self else { return }
            
            actionView.sortBadgeNumber = self.sortConfiguration.numberOfChanges
            
            print(Sort.allCases.map { "\($0.rawValue) -> \(self.sortConfiguration.option(for: $0.rawValue)?.isSelected ?? false)" }.joined(separator: "\n"))

        }
        .store(in: &cancellables)
        
        
        filterConfiguration.stateDidChange.send()
        sortConfiguration.stateDidChange.send()
        
        actionView.actionHandler = { [weak self] action, sourceView in
            guard let self  else { return }
        
            let configuration = switch action {
            case .filter:
                self.filterConfiguration
        
            case .sort:
                self.sortConfiguration
            }
            
            let menu = OptionMenu(configuration: configuration, presentationStyle: .drawer, presentingViewController: presentingViewController, sourceView: sourceView)
          
            menu.activate()
        }
        
        addRow([titleLabel, flexibleSpacer, actionView])
                
    }
}
