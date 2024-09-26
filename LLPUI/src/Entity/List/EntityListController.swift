//
//  EntityListController.swift
//  LLPUI
//
//  Created by xueqooy on 2024/6/12.
//

import UIKit
import LLPUtils
import Combine


public class EntityListController: UIViewController {
            
    public static let rowHeight: CGFloat = 52

    public struct Action: OptionSet {
        
        public var rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static let search = Action(rawValue: 1)
        public static let multiSelect = Action(rawValue: 1 << 1)
        
        
        public static let all: Action = [.search, .multiSelect]
    }
    
    public var dataSource: EntityListDataSource {
        didSet {
            reloadDataSource()
        }
    }
        
    private lazy var listBuilder: GenericListBuilder = .init(configuration: .init(cellTypeProvider: { index, sectionContext in
        
        if sectionContext.object is PersonaEntity {
            return EntityListPersonaCell.self
        } else {
            return EntityListGroupCell.self
        }
        
    }, cellConfigurator: { [weak self] cell, index, sectionContext in
        guard let self else { return }
        
        let entity = sectionContext.object as! Entity
        
        let isMultiSelect = self.action.contains(.multiSelect)
        
        if isMultiSelect {
            let isSelected = self.identifiersForSelectedEntities.contains(entity.id.entityIdentifier)
        
            if isSelected {
                self.listBuilder.listController.listView.selectItem(at: IndexPath(item: index, section: sectionContext.section), animated: false, scrollPosition: [])
            
            } else {
                self.listBuilder.listController.listView.deselectItem(at: IndexPath(item: index, section: sectionContext.section), animated: false)
            }
        }
     
        if let personaEntity = entity as? PersonaEntity {
            let cell = cell as! EntityListPersonaCell
            cell.bindViewModel(personaEntity)
            cell.displayCheckmarkWhenSelected = isMultiSelect
            
        } else if let groupEntity = entity as? GroupEntity {
            let cell = cell as! EntityListGroupCell
            cell.bindViewModel(groupEntity)
            cell.displayCheckmarkWhenSelected = isMultiSelect
        }
        
    }, cellSizeProvider: { index, sectionContext in
        
        CGSizeMake(sectionContext.sectionContainerWidth, Self.rowHeight)

    }, itemDidSelectHandler: { [weak self] index, sectionContext in
        guard let self else { return }
        
        let entity = self.displayedEntities[sectionContext.section]
        
        if self.action.contains(.multiSelect) {
            self.identifiersForSelectedEntities.add(entity.id.entityIdentifier)
            self.maybeUpdateApplyButtonTitle()
            
        } else {
            self.selectHandler([entity])
        }
        
    }, itemDidDeselectHandler: { [weak self] index, sectionContext in
        guard let self, self.action.contains(.multiSelect) else { return }
        
        let entity = self.displayedEntities[sectionContext.section]
        
        self.identifiersForSelectedEntities.remove(entity.id.entityIdentifier)
        self.maybeUpdateApplyButtonTitle()
    }))
  
    private lazy var emptyView = EmptyView(configuration: .init(text: Strings.searchWithNoResults))
    
    private lazy var titleAndClearButtonView = TitleAndButtonView(title: title, buttonConfiguration: action.contains(.multiSelect) ? .init(title: Strings.clear) : nil, buttonAction: action.contains(.multiSelect) ? { [weak self] _ in
        guard let self else { return }
    
        // Clear selection
        self.identifiersForSelectedEntities.removeAllObjects()
        self.maybeUpdateApplyButtonTitle()
        
        let listView = self.listBuilder.listController.listView
        listView.indexPathsForSelectedItems?.forEach {
            listView.deselectItem(at: $0, animated: false)
        }
        
        self.listBuilder.listController.listView.reloadData()
        
    } : nil)
    
    private lazy var searchField = SearchInputField(placeholder: Strings.search)
    
    private lazy var applyButton = Button(designStyle: .primary, title: Strings.apply).then {
        $0.touchUpInsideAction = { [weak self] _ in
            guard let self else { return }
            // Apply selection
            self.resolveSelectionForMultiSelect()
        }
    }
    
    private var identifiersForSelectedEntities = NSMutableOrderedSet()
    
    private var identifierToEntityMap = [String : Entity]()
    
    private var displayedEntities: [Entity] = [] {
        didSet {
            listBuilder.objects = displayedEntities
        }
    }
    
    private var searchTextSubscription: AnyCancellable?
    
    private var curDataTaskID: UUID?
    
    private var action: Action
    
    private let selectHandler: ([Entity]) -> Void
        
            
    public init(action: Action, dataSource: EntityListDataSource = [], selection: [Entity] = [], selectHandler: @escaping ([Entity]) -> Void) {
        self.action = action
        self.dataSource = dataSource
        self.selectHandler = selectHandler
        
        super.init(nibName: nil, bundle: nil)
    
        // Set initial selection for multi select
        if action.contains(.multiSelect) {
            selection.forEach { entity in
                identifiersForSelectedEntities.add(entity.id.entityIdentifier)
                identifierToEntityMap[entity.id.entityIdentifier] = entity
            }
            
            maybeUpdateApplyButtonTitle()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let listView = listBuilder.listController.listView
        listView.allowsMultipleSelection = action.contains(.multiSelect)
    
        Task {
            listBuilder.listController.emptyView = emptyView
        }
        
        let showsTitle = !(title?.isEmpty ?? true)
        let showsSearchField = action.contains(.search)
        let showsMultiSelectComponents = action.contains(.multiSelect)
        
        view.addForm(scrollingBehavior: .disabled) { formView in
            formView.itemSpacing = .LLPUI.spacing7
            formView.contentInset = .nondirectionalZero
            
        } populate: {
            if showsTitle || showsMultiSelectComponents {
                FormRow(titleAndClearButtonView)
            }
            
            if showsSearchField {
                FormRow(searchField)
            }
            
            FormRow(listView)
            
            if showsMultiSelectComponents {
                FormRow(applyButton, alignment: .center)
            }
        }
        
        // Observe search
        searchTextSubscription = searchField.textPublisher
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] in
                guard let self else { return }
                
                self.loadEntities(withQuery: $0)
            }
        
        // First load
        loadEntities(withQuery: nil)
    }
    
    public func reloadDataSource() {
        loadEntities(withQuery: searchField.text)
    }
    
    private func maybeUpdateApplyButtonTitle() {
        guard action.contains(.multiSelect) else { return }
        
        if identifiersForSelectedEntities.count == 0 {
            applyButton.configuration.title = Strings.apply
        } else {
            applyButton.configuration.title = Strings.apply + " (\(identifiersForSelectedEntities.count))"
        }
    }
    
    private func loadEntities(withQuery query: String? = nil) {
        let taskID = UUID()
        curDataTaskID = taskID
        
        Task { @MainActor in
            displayedEntities = []

            emptyView.configuration.isLoading = true
                    
            let entities = await dataSource.getEntities(withQuery: query)
         
            // Update map
            entities.forEach { entity in
                identifierToEntityMap[entity.id.entityIdentifier] = entity
            }
            
            if curDataTaskID == taskID {
                displayedEntities = entities
                
                if entities.isEmpty {
                    emptyView.configuration.isLoading = false
                }
            }
        }
    }
    
    private func resolveSelectionForMultiSelect() {
        var entities = [Entity]()
        
        identifiersForSelectedEntities.forEach { identifier in
            if let entity = identifierToEntityMap[identifier as! String] {
                entities.append(entity)
            } else {
                Logs.error("identifier \(identifier) has no corresponding entity")
            }
        }
        
        selectHandler(entities)
    }
}

