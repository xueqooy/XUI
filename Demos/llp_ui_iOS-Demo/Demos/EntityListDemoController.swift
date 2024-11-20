//
//  EntityListDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2024/5/31.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI
import LLPUtils
import Combine

class EntityListDemoController: DemoController {
    
    private let dateLabel = UILabel(text: "Due on : 2022/06/14 23:59", textColor: Colors.bodyText1, font: Fonts.body3)
    
    private let assigneeLabel = UILabel(text: "Assigned to:", textColor: Colors.bodyText1, font: Fonts.body3)
        .settingContentCompressionResistanceAndHuggingPriority(.required)
    
    private let assignees: [Entity] = [
        GroupEntity(id: "1", name: "English Class", color: Colors.mediumTeal),
        GroupEntity(id: "2", name: "Math Class", color: Colors.red),
        GroupEntity(id: "3", name: "Small Group 2", color: Colors.green, parentEntityName: "English Class"),
        PersonaEntity(id: "4", name: "Student wang", avatarURLConfiguration: .init(preferredURL: URL.randomImageURL(width: 40, height: 40))),
        GroupEntity(id: "5", name: "Math Class 2", color: Colors.extraLightTeal),
        PersonaEntity(id: "6", name: "Teacher zhang", avatarURLConfiguration: .init(preferredURL: URL.randomImageURL(width: 40, height: 40))),
        GroupEntity(id: "7", name: "Phy Class", color: Colors.red),
    ]
    
    private lazy var assigneeBadgeContainerView = EntityBadgeContainerView(maxDisplayCount: 6, entities: assignees) { [weak self] view, target in
        switch target {
        case .entity(let entity):
            print(entity)
        case .viewAll(let array):
            self?.showList(with: array, from: view)
        }
    }
    
    private lazy var cancellableAssigneeBadgeContainerView = EntityBadgeContainerView(maxDisplayCount: 6, cancellable: true, entities: assignees) { [weak self] view, target in
        switch target {
        case .entity(let entity):
            print(entity)
        case .viewAll(let array):
            self?.showList(with: array, from: view)
        }
    }
    
    private lazy var assigneeBadgeField = EntityBadgeField(entities: assignees, selectionDataSource: AssigneeListDataSource(assignees: assignees), label: "Assignees", placeholder: "Select assignees")
     
    private lazy var assigneeNameField = InputField(placeholder: "Assignee Name")
    
    private lazy var assigneeTypeSegmentControl = SegmentControl(style: .page, items: ["Persona", "Group", "SmallGroup"]).then {
        $0.selectedSegmentIndex = 0
    }
    
    private lazy var addAssigneeButton = Button(designStyle: .primary, title: "Add Assignee") { [weak self] _ in
        guard let self, let name = assigneeNameField.text, !name.isEmpty else {
            return
        }
        
        let entity: Entity
        
        switch self.assigneeTypeSegmentControl.selectedSegmentIndex {
        case 1:
            entity = GroupEntity(id: UUID().uuidString, name: name, color: UIColor.randomColor())
            
        case 2:
            entity = GroupEntity(id: UUID().uuidString, name: name, color: UIColor.randomColor(), parentEntityName: "Parent Entity")
            
        default:
            entity = PersonaEntity(id: UUID().uuidString, name: name, avatarURLConfiguration: .init(preferredURL: URL.randomImageURL(width: 28, height: 28)))
        }
        
        self.addAssignee(entity)
    }

    
    private let stateLabel = UILabel(text: "State: Assigned", textColor: Colors.bodyText1, font: Fonts.body3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        addRow(dateLabel, alignment: .fill)
            .settingCustomSpacingAfter(5)
        
        addRow([assigneeLabel, assigneeBadgeContainerView], itemSpacing: 4, verticalAlignment: .top, alignment: .fill)
            .settingCustomSpacingAfter(3)
        
        addRow(stateLabel, alignment: .fill)
            .settingCustomSpacingAfter(.LLPUI.spacing4)
        
        addSeparator()
        
        addRow(cancellableAssigneeBadgeContainerView, alignment: .fill)
            .settingCustomSpacingAfter(.LLPUI.spacing4)
        
        addSeparator()
        
        addRow(assigneeBadgeField, alignment: .fill)
            .settingCustomSpacingAfter(.LLPUI.spacing4)
        
        addSeparator()
        
        addRow(assigneeNameField, alignment: .fill)
            .settingCustomSpacingAfter(.LLPUI.spacing3)
        
        addRow(assigneeTypeSegmentControl, alignment: .center)
            .settingCustomSpacingAfter(.LLPUI.spacing3)
        
        addRow(addAssigneeButton)
    }
    
    private func showList(with assignees: [Entity], from sourceView: UIView) {
        let listController = EntityListController(action: [.search], dataSource: assignees) {
            print($0)
        }
        listController.title = "Assignees"
        
        let drawer = DrawerController(sourceView: sourceView, configuration: .init(resizingBehavior: .dismissOrExpand))
        drawer.contentController = listController
        drawer.preferredContentSize = CGSize(width: 350, height: 500)
        
        present(drawer, animated: true)
    }
    
    private func addAssignee(_ entity: Entity) {
        assigneeBadgeContainerView.entities.append(entity)
        
        cancellableAssigneeBadgeContainerView.entities.append(entity)
        
        assigneeBadgeField.entities.append(entity)
        
        (assigneeBadgeField.selectionDataSource as! AssigneeListDataSource).assignees.append(entity)
    }
}


class AssigneeListDataSource: EntityListDataSource {
    
    var assignees: [Entity]
    
    private var hasRequestedAll: Bool = false
    
    init(assignees: [Entity]) {
        self.assignees = assignees
    }
    
    func getEntities(withQuery query: String?) async -> [LLPUI.Entity] {
        if let query, !query.isEmpty {
            try? await Task.sleep(nanoseconds: 500_000_000)

            return assignees.filter({ $0.name.lowercased().contains(query.lowercased()) })
            
        } else {
            if hasRequestedAll {
                return assignees
            }
            
            hasRequestedAll = true
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            return assignees
        }
    }
    
}
