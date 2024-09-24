//
//  FilterSortActionDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/9/5.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI
import LLPUtils
import Combine

class FilterSortActionDemoController: DemoController {
    private let object = FilterSortObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel(text: "What’s On", textColor: Colors.title, font: Fonts.h6)
        let flexibleSpacer = HSpacerView.flexible()
        let actionView = FilterSortActionView()
        
        object.stateDidChange.sink { [weak self] in
            guard let self = self else { return }
            
            actionView.filterBadgeNumber = self.object.filter.changes
            actionView.sortBadgeNumber = self.object.sort.changes
        }
        .store(in: &cancellables)
        
        actionView.actionHandler = { [weak self] action, sourceView in
            guard let self = self else { return }
            
            let type: FilterSortOptionsController.OptionsType
            switch action {
            case .filter:
                type = .filter
            case .sort:
                type = .sort
            }
            
            let viewModel = FilterSortOptionsViewModel(object: self.object)
            let viewController = FilterSortOptionsController(type: type, viewModel: viewModel)
            viewController.show(from: sourceView, sourceViewController: self)
        }
        
        addRow([titleLabel, flexibleSpacer, actionView])
        
        
    }
}

private class FilterSortObject: StateObservableObject {
    
    struct Filter: Equatable {
        enum `Type`: Equatable {
            case assignments, polls, quizzes
        }
        
        enum Author: Equatable {
            case byMe, byOthers
        }
        
        var classActivityOnly: Bool = false
        
        var type: `Type`?
        
        var author: Author?
        
        var changes: Int {
            var result: Int = 0
            
            if classActivityOnly {
                result += 1
            }
            
            if type != nil {
                result += 1
            }
            
            if author != nil {
                result += 1
            }
            
            return result
        }
    }
    
    enum Sort: Equatable {
        case latestPosts, latestActivity
        
        var changes: Int {
            self == .latestActivity ? 1 : 0
        }
    }

    @EquatableState
    var filter: Filter = .init()
    
    @EquatableState
    var sort: Sort = .latestPosts
}


private class FilterSortOptionsController: UIViewController {
    enum OptionsType {
        case filter, sort
    }
    
    let type: OptionsType
    let viewModel: FilterSortOptionsViewModel
    
    private var cancellable: AnyCancellable?
    
    init(type: OptionsType, viewModel: FilterSortOptionsViewModel) {
        self.type = type
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        cancellable = viewModel.output.applied
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true)
            })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        switch type {
        case .filter:
            let view = FilterOptionsView()
            view.bindViewModel(viewModel)
            self.view = view
        case .sort:
            let view = SortOptionsView()
            view.bindViewModel(viewModel)
            self.view = view
        }
    }
    
    func show(from sourceView: UIView, sourceViewController: UIViewController) {
        preferredContentSize = CGSize(width: 375, height: 0)
        
        let drawer = DrawerController(sourceView: sourceView, configuration: .init(resizingBehavior: .dismiss))
        drawer.contentController = self
        
        sourceViewController.present(drawer, animated: true)
    }
}


private class FilterSortOptionsViewModel {

    struct Output {
        let applied = PassthroughSubject<Void, Never>()
    }
    
    typealias Filter = FilterSortObject.Filter
    typealias Sort = FilterSortObject.Sort
    
    var filter: Filter {
        object.filter
    }
    
    var sort: Sort {
        object.sort
    }
    
    let output = Output()
    
    private let object: FilterSortObject
    
    init(object: FilterSortObject) {
        self.object = object
    }
    
    func applySort(_ sort: Sort) {
        object.sort = sort
        output.applied.send()
    }
    
    func applyFilter(_ filter: Filter) {
        object.filter = filter
        output.applied.send()
    }
}



private class FilterOptionsView: BindingView {
    private let titleLabel = UILabel(text: "Filter", textColor: Colors.title, font: Fonts.body1Bold, textAlignment: .center)
    
    private let clearButton = LLPUI.Button(designStyle: .borderless, title: "Clear")
    
    private let classActivityOnlyCheckbox = OptionControl(style: .checkbox, titlePlacement: .leading, title: "Class activity only")
    
    private let typeSectionLabel = UILabel(text: "Type", textColor: Colors.bodyText1, font: Fonts.body1Bold)
    
    private let assignmentsRadio = OptionControl(style: .radio, titlePlacement: .leading, title: "Assignments")
    
    private let pollsRadio = OptionControl(style: .radio, titlePlacement: .leading, title: "Polls")
        
    private let quizzesRadio = OptionControl(style: .radio, titlePlacement: .leading, title: "Quizzes")
    
    private let authorSectionLabel = UILabel(text: "Author", textColor: Colors.bodyText1, font: Fonts.body1Bold)

    private let byMeRadio = OptionControl(style: .radio, titlePlacement: .leading, title: "By Me")

    private let byOthersRadio = OptionControl(style: .radio, titlePlacement: .leading, title: "By Others")
    
    private let applyButton = LLPUI.Button(designStyle: .primary, contentInsetsMode: .ignoreHorizontal, title: "Apply")
    
    private let typeRadioGroup = SingleSelectionGroup()
    private let authorRadioGroup = SingleSelectionGroup()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [assignmentsRadio, pollsRadio, quizzesRadio].forEach { $0.singleSelectionGroup = typeRadioGroup }
        [byMeRadio, byOthersRadio].forEach { $0.singleSelectionGroup = authorRadioGroup }

        addForm(scrollingBehavior: .disabled) { formView in
            formView.contentInset = .directionalZero
            formView.itemSpacing = 0
        } populate: {
            FormRow(titleLabel)
            FormSpacer(40)
            FormRow(classActivityOnlyCheckbox)
            FormSpacer(40)
            FormRow(typeSectionLabel)
            FormSpacer(16)
            FormRow(assignmentsRadio)
            FormSpacer(28)
            FormRow(pollsRadio)
            FormSpacer(28)
            FormRow(quizzesRadio)
            FormSpacer(40)
            FormRow(authorSectionLabel)
            FormSpacer(16)
            FormRow(byMeRadio)
            FormSpacer(28)
            FormRow(byOthersRadio)
            FormSpacer(40)
            FormRow(applyButton)
        }
        
        addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: FilterSortOptionsViewModel) {
        updateViewModel(viewModel)
        
        var filter = viewModel.filter
        
        setup(with: filter)
        
        classActivityOnlyCheckbox.seletionStateChangedAction = {
            filter.classActivityOnly = $0.isSelected
        }
        
        assignmentsRadio.seletionStateChangedAction = {
            if $0.isSelected {
                filter.type = .assignments
            }
        }
        
        pollsRadio.seletionStateChangedAction = {
            if $0.isSelected {
                filter.type = .polls
            }
        }
        
        quizzesRadio.seletionStateChangedAction = {
            if $0.isSelected {
                filter.type = .quizzes
            }
        }
        
        byMeRadio.seletionStateChangedAction = {
            if $0.isSelected {
                filter.author = .byMe
            }
        }
        
        byOthersRadio.seletionStateChangedAction = {
            if $0.isSelected {
                filter.author = .byOthers
            }
        }
        
        clearButton.touchUpInsideAction = { [weak self] _ in
            filter = .init()
            
            self?.setup(with: filter)
        }
        
        applyButton.touchUpInsideAction = { _ in
            viewModel.applyFilter(filter)
        }
    }
    
    private func setup(with filter: FilterSortOptionsViewModel.Filter) {
        classActivityOnlyCheckbox.isSelected = filter.classActivityOnly
        
        switch filter.type {
        case .assignments:
            assignmentsRadio.isSelected = true
        case .polls:
            pollsRadio.isSelected = true
        case .quizzes:
            quizzesRadio.isSelected = true
        default:
            assignmentsRadio.isSelected = false
            pollsRadio.isSelected = false
            quizzesRadio.isSelected = false
        }
        
        switch filter.author {
        case .byMe:
            byMeRadio.isSelected = true
        case .byOthers:
            byOthersRadio.isSelected = true
        default:
            byMeRadio.isSelected = false
            byOthersRadio.isSelected = false
        }
    }
}


private class SortOptionsView: BindingView {
    
    private let titleLabel = UILabel(text: "Sort", textColor: Colors.title, font: Fonts.body1Bold, textAlignment: .center)
    
    private let clearButton = LLPUI.Button(designStyle: .borderless, title: "Clear")
    
    private let latestPostsRadio = OptionControl(style: .radio, titlePlacement: .leading, title: "Latest Posts")
    
    private let latestActivityRadio = OptionControl(style: .radio, titlePlacement: .leading, title: "Latest Activity")
    
    private let applyButton = LLPUI.Button(designStyle: .primary, contentInsetsMode: .ignoreHorizontal, title: "Apply")
    
    private let radioGroup = SingleSelectionGroup()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        latestPostsRadio.singleSelectionGroup = radioGroup
        latestActivityRadio.singleSelectionGroup = radioGroup
        
        addForm(scrollingBehavior: .disabled) { formView in
            formView.contentInset = .directionalZero
            formView.itemSpacing = 0
        } populate: {
            FormRow(titleLabel)
            FormSpacer(40)
            FormRow(latestPostsRadio)
            FormSpacer(28)
            FormRow(latestActivityRadio)
            FormSpacer(40)
            FormRow(applyButton)
        }
        
        addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: FilterSortOptionsViewModel) {
        updateViewModel(viewModel)
        
        var sort = viewModel.sort
        
        setup(with: sort)
        
        latestPostsRadio.seletionStateChangedAction = {
            if $0.isSelected {
                sort = .latestPosts
            }
        }
        
        latestActivityRadio.seletionStateChangedAction = {
            if $0.isSelected {
                sort = .latestActivity
            }
        }
        
        clearButton.touchUpInsideAction = { [weak self] _ in
            sort = .latestPosts
            
            self?.setup(with: sort)
        }
        
        applyButton.touchUpInsideAction = { _ in
            viewModel.applySort(sort)
        }
    }
    
    private func setup(with sort: FilterSortOptionsViewModel.Sort) {
        switch sort {
        case .latestPosts:
            latestPostsRadio.isSelected = true
        case .latestActivity:
            latestActivityRadio.isSelected = true
        }
    }
}

