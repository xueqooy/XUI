//
//  MainController.swift
//  XUI_Example
//
//  Created by 🌊 薛 on 2022/9/19.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import XUI
import Combine
import XKit
import DemoMacro

struct DemoSection {
    let title: String
    let demos: [Demo]
}

@DemoEnum
enum Demo: String {
    case Button
    case InputField
    case CodeField
    case SegmentControl
    case OptionControl
    case PageControl
    case Toast
    case Tooltip
    case Popover
    case Drawer
    case Popup
    case Coachmark
    case Form
    case Grid
    case SegmentedPage
    case NestedScrolling
    case List
    case Carousel
    case KeyboardManager
    case RichText
    case Badge
    case LinkedLabel
    case Sketch
    case Background
    case Separator
    case SteppedProgress
    case FilterSortAction
    case TripleImage
    case Avatar
    case Empty
    case Media
    case MessageInputBar
    case ActionSheet
    case ConfirmationDialog
    case Icons
    case Persona
    case RangeSlider
    case ColorPicker
    case HUD
    case ActionBar
    case OptionMenu
    case DatePicker
    case BarChart
    case DropdownMenu
    case EntityList
    case CountdownTimer
}

class MainController: UITableViewController {
    
    var versionButtonItem: UIBarButtonItem!
    var toggleDirectionButtonItem: UIBarButtonItem!

    let demoSections: [DemoSection] = [
        DemoSection(title: "Control", demos: [
            .Button,
            .SegmentControl,
            .OptionControl,
            .PageControl,
            .RangeSlider
        ]),
        DemoSection(title: "Field", demos: [
            .InputField,
            .CodeField,
            .DatePicker
        ]),
        DemoSection(title: "Tips", demos: [
            .Toast,
            .Tooltip,
            .Popover,
            .HUD
        ]),
        DemoSection(title: "Presentation", demos: [
            .Drawer,
            .Popup,
            .Coachmark,
            .ActionSheet,
            .ConfirmationDialog
        ]),
        DemoSection(title: "Container", demos: [
            .Form,
            .Grid,
            .SegmentedPage,
            .NestedScrolling,
            .List,
            .Carousel,
            .TripleImage
        ]),
        DemoSection(title: "Utilities", demos: [
            .KeyboardManager,
            .RichText,
            .Icons
        ]),
        DemoSection(title: "", demos: [
            .Badge,
            .LinkedLabel,
            .Sketch,
            .Background,
            .Separator,
            .SteppedProgress,
            .FilterSortAction,
            .Empty,
            .Avatar,
            .Media,
            .MessageInputBar,
            .ActionBar,
            .Persona,
            .ColorPicker,
            .OptionMenu,
            .BarChart,
            .DropdownMenu,
            .EntityList,
            .CountdownTimer
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        navigationItem.title = "XUI"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Set up direction toggle button
        let isLTR = UIView.userInterfaceLayoutDirection(for: UIView.appearance().semanticContentAttribute) == .leftToRight
        
        versionButtonItem = UIBarButtonItem(title: ChangeLog.latestVersion, style: .plain, target: self, action: #selector(Self.showChangeLog))
        
        toggleDirectionButtonItem = UIBarButtonItem(image: .init(named: isLTR ? "rtl" : "ltr"), style: .plain, target: self, action: #selector(Self.toggleInterfaceDirection))
        
        navigationItem.leftBarButtonItem = versionButtonItem
        navigationItem.rightBarButtonItem = toggleDirectionButtonItem
    }
    
    func showDemo(_ demo: Demo) {
        let viewController = demo.viewController
        if let editable = viewController as? Editable {
            editable.startEditing()
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func toggleInterfaceDirection() {
        let isLTR = UIView.userInterfaceLayoutDirection(for: UIView.appearance().semanticContentAttribute) == .leftToRight
        
        UIView.appearance().semanticContentAttribute = isLTR ? .forceRightToLeft : .forceLeftToRight
        UINavigationBar.appearance().semanticContentAttribute = isLTR ? .forceRightToLeft : .forceLeftToRight

        // Reload all view controller
        UIApplication.shared.delegate?.window??.rootViewController = UINavigationController(rootViewController: MainController(style: .insetGrouped))
    }
    
    @objc private func showChangeLog() {
        ChangeLogController().show(from: versionButtonItem)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let demo = demoSections[indexPath.section].demos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        if #available(iOS 14.0, *) {
            var config = UIListContentConfiguration.cell()
            config.text = demo.title
            cell.contentConfiguration = config
        } else {
            // Fallback on earlier versions
            cell.textLabel?.text = demo.title
        }
                
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        demoSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        demoSections[section].demos.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        demoSections[section].title
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let demo = demoSections[indexPath.section].demos[indexPath.row]
        showDemo(demo)
    }
    
}

//struct Comparation {
//    
//    private let closure: () -> Bool
//    
//    init(_ closure: @escaping () -> Bool) {
//        self.closure = closure
//    }
// 
//    func perform() -> Bool {
//        closure()
//    }
//}
//
//func compare<T, each U>(lhs: T, rhs: T, keypath: repeat KeyPath<T, each U>) -> Bool where repeat each U: Equatable {
//    var comparations = [Comparation]()
//    
//    repeat comparations.append(Comparation({ lhs[keyPath: each keypath] == rhs[keyPath: each keypath] }))
//    
//    for comparation in comparations {
//        if comparation.perform() == false {
//            return false
//        }
//    }
//    
//    return true
//}
