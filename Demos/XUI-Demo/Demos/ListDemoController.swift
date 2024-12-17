//
//  ListDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/8/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI
import XList
import IGListKit
import IGListSwiftKit
import XKit
import Combine

class ListDemoController: DemoController {
    
    private let listController = ListController(scrollDirection: .vertical)
    
    private let toastObject = ListToastObject(configuration: .init(style: .note, message: "For security reasons, the password for each selected student account will be reset."))
    
    private let emptyObject = ListEmptyObject(configuration: .init(text: "Empty Text", detailText: "Empty Detail Text Empty Detail Text Empty Detail Text Empty Detail Text Empty Detail Text"))
    
    private let spacerObject = ListSpacer(spacing: 50)
    
    private lazy var rightBarButtonItem = UIBarButtonItem(image: .init(systemName: "rectangle.split.1x2.fill"), style: .plain, target: self, action: #selector(Self.changeListStyle))
    
    private var isSingleItemInSection: Bool = true {
        didSet {
            rightBarButtonItem.image = .init(systemName: isSingleItemInSection ? "rectangle.split.1x2.fill" : "rectangle.grid.1x2.fill")
            Task {
                await listController.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        view.backgroundColor = Colors.background1
        
        formView.backgroundColor = .clear

        setupList()
        
        let nestedScrollingView = NestedScrollingView()
        nestedScrollingView.headerView = HeaderView(listController: listController)
        nestedScrollingView.contentView = listController.listView
        nestedScrollingView.bounceTarget = .child
        
        view.addSubview(nestedScrollingView)
        nestedScrollingView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }      
        
        emptyObject.configuration.isLoading = true
        
        Queue.main.execute(.delay(3)) {
            self.emptyObject.configuration.isLoading = false
            self.toastObject.update { configuration in
                configuration.style = .error
                configuration.richMessage = "\("0%", .action { print("tapped") }, .foreground(Colors.teal)) of your students have parents following their progress."
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let configuration = PopupController.Configuration(title: "Generic List")

        let popupController = PopupController(configuration: configuration)
        popupController.contentController = BindingListViewController()
        popupController.preferredContentSize = CGSize(width: 350, height: 500)
        present(popupController, animated: true)
    }
    
    private func setupList() {
        listController.viewController = self
        
        self.listController.sectionControllerProvider = { [weak self] _ in
            guard let self = self else {
                return LabelSectionController()
            }
            
            return self.isSingleItemInSection ? LabelSectionController() : MultipleLabelSectionController()
        }
        
        listController.loadMoreHandler = { [weak self] listController in
            print("Start loading more")
            
            DispatchQueue.global(qos: .default).async {
                // fake background loading task
                sleep(1)
                DispatchQueue.main.async {
                    self?.appendData()
                    listController.endLoadingMore()
                }
            }
        }
        
        listController.refreshHandler = { [weak self] listController in
            print("Start refreshing")
            
            DispatchQueue.global(qos: .default).async {
                // fake background loading task
                sleep(1)
                DispatchQueue.main.async {
                    self?.initializeData()
                    listController.endRefreshing()
                }
            }
        }
        
        initializeData()
    }
    
    private func initializeData() {
        var objects: [ListDiffable] = [toastObject, emptyObject]
        objects.append(contentsOf: (0...20).reduce(into: [ListDiffable](), { partialResult, value in
            partialResult.append(value as ListDiffable)
        }) as [ListDiffable])
        
        listController.objects = objects
    }
    
    private func appendData() {
        Task {
            let currentIndex = listController.objects.last as! Int
            let appendedObjects = (currentIndex...(currentIndex + 10)).reduce(into: [ListDiffable](), { partialResult, value in
                partialResult.append(value as ListDiffable)
            }) as [ListDiffable]
                                    
            await listController.appendObjects(appendedObjects)
        }
    }
    
    @objc private func changeListStyle() {
        isSingleItemInSection.toggle()
    }
}

private class HeaderView: UIView, NestedScrollingHeader {
    
    private var cancellables = Set<AnyCancellable>()
    
    init(listController: ListController) {
        super.init(frame: .zero)

        let refreshButton = Button(designStyle: .primary, contentInsetsMode: .ignoreHorizontal, title: "Refresh") { _ in
            listController.beginRefreshing()
        }
        refreshButton.isEnabled = false
        
        let loadMoreButton = Button(designStyle: .primary, contentInsetsMode: .ignoreHorizontal, title: "Load More") { _ in
            listController.beginLoadingMore()
        }
        loadMoreButton.isEnabled = false
        
        listController.isRefreshingPublisher
            .sink { [weak refreshButton] isRefreshing in
                refreshButton?.configuration.showsActivityIndicator = isRefreshing
            }
            .store(in: &cancellables)
        
        listController.isLoadingMorePublisher
            .sink { [weak loadMoreButton] isLoadingMore in
                loadMoreButton?.configuration.showsActivityIndicator = isLoadingMore
            }
            .store(in: &cancellables)
        
        let canRefreshSwitch = OptionControl(style: .switch, titlePlacement: .leading, title: "Can Refresh")
        canRefreshSwitch.seletionStateChangedAction = { control in
            listController.canRefresh = control.isSelected
            refreshButton.isEnabled = control.isSelected
        }
        
        let canLoadMoreSwitch = OptionControl(style: .switch, titlePlacement: .leading, title: "Can Load More")
        canLoadMoreSwitch.seletionStateChangedAction = { control in
            listController.canLoadMore = control.isSelected
            loadMoreButton.isEnabled = control.isSelected
        }
        
        let reorderGestureEnabledSwitch = OptionControl(style: .switch, titlePlacement: .leading, title: "Reorder Gesture Enabled")
        reorderGestureEnabledSwitch.seletionStateChangedAction = { control in
            listController.isReorderGestrueEnabled = control.isSelected
        }

        addForm { formView in
            formView.itemSpacing = 10
        } populate: {
            FormRow(canRefreshSwitch)
            FormRow(canLoadMoreSwitch)
            FormRow(reorderGestureEnabledSwitch)
            FormRow([refreshButton, loadMoreButton], spacing: 20, height: 29, distribution: .fillEqually)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class LabelSectionController: ListSectionController {
    private var object: String?
    
    override init() {
        super.init()
    }

    override func sizeForItem(at index: Int) -> CGSize {
        managedCellSize(of: LabelCell.self, for: object!)
//        ListCellSizeManager<LabelCell>.shared.size(for: object!, containerWidth: sectionContainerWidth)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: LabelCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.text = object
        return cell
    }

    override func didUpdate(to object: Any) {
        let intValue = object as! Int
        
        connectionRole = intValue % 10 == 0 ? .parent : .child
                
        self.object = String(describing: intValue)
    }

    
    override func canMoveItem(at index: Int) -> Bool {
        true
    }
    
    var connectionRole: ListSectionConnectionConfiguration.Role = .parent {
        didSet {
            
            // Left to Right Connection
            inset = .init(top: 10, left: connectionRole == .parent ? 20 : 60, bottom: 0, right: 20)
            
            // Center Connection
//            inset = .init(top: 10, left: 20, bottom: 0, right: 20)
            
            // Right to Left Connection
//            inset = .init(top: 10, left: 20, bottom: 0, right: connectionRole == .parent ? 20 : 60)
        }
    }
}

extension LabelSectionController: ListSectionBackgroundConfigurationProviding {
    var sectionBackgroundConfiguration: BackgroundConfiguration? {
        .overlay().with {
            $0.stroke.color = Colors.teal
            $0.stroke.width = 1
        }
    }
}

extension LabelSectionController: ListSectionConnectionConfigurationProviding {
    var sectionConnectionConfiguration: ListSectionConnectionConfiguration? {
        // Left to Right Connection
        .init(role: connectionRole, anchor: connectionRole == .parent ? .init(relativePosition: .init(x: 0, y: 1), offset: .init(horizontal: 20, vertical: 0)) : .init(relativePosition: .init(x: 0, y: 0.5), offset: .zero))
        
        // Center Connection
//        .init(role: connectionRole, anchor: connectionRole == .parent ? .init(relativePosition: .init(x: 0.5, y: 1), offset: .zero) : .init(relativePosition: .init(x: 0.5, y: 0), offset: .zero))
        
        // Right to Left Connection
//        .init(role: connectionRole, anchor: connectionRole == .parent ? .init(relativePosition: .init(x: 1, y: 1), offset: .init(horizontal: -20, vertical: 0)) : .init(relativePosition: .init(x: 1, y: 0.5), offset: .zero))
    }
}


private class MultipleLabelSectionController: ListSectionController {

    private var object: String?

    override init() {
        super.init()
        
        inset = .init(top: 20, left: 20, bottom: 0, right: 20)
    }
    
    override func numberOfItems() -> Int {
        5
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        managedCellSize(of: LabelCell.self, for: "\(object!)-\(index)")
//        ListCellSizeManager<LabelCell>.shared.size(for: "\(object!)-\(index)", containerWidth: sectionContainerWidth)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: LabelCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.text = "\(object!)-\(index)"
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = String(describing: object)
    }
}



extension MultipleLabelSectionController: ListSectionBackgroundConfigurationProviding {
    var sectionBackgroundConfiguration: BackgroundConfiguration? {
        .overlay().with {
            $0.stroke.color = Colors.teal
            $0.stroke.width = 1
        }
    }
}

extension MultipleLabelSectionController: ListSectionInnerBackgroundConfigurationProviding {
    var sectionInnerBackgroundItems: Set<Int>? {
        [0, 1, 3, 4]
    }
    
    func sectionInnerBackgroundInset(for range: Range<Int>) -> Insets {
        if range.contains(3) {
            return .nondirectional(top: .XUI.spacing3, left: .XUI.spacing5, bottom: .XUI.spacing3, right: .XUI.spacing5)
        } else {
            return .nondirectional(uniformValue: .XUI.spacing3)
        }
    }
   
    func sectionInnerBackgroundConfiguration(for range: Range<Int>) -> BackgroundConfiguration? {
        .overlay().with {
            $0.stroke.width = 1

            if range.contains(3) {
                $0.stroke.color = Colors.lightRed
            } else {
                $0.stroke.color = Colors.green
            }
        }
    }

}

private class LabelCell: UICollectionViewCell {
    fileprivate static let insets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    
    fileprivate let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = Fonts.body2Bold
        return label
    }()
    
    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        label.sizeToFit()
        label.center = contentView.center
    }
}

extension LabelCell: ListBindable {

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? String else { return }
        label.text = viewModel
    }

}


extension LabelCell: ListCellSizeProviding {
    var cellSize: CGSize {
        let extent = CGFloat.random(in: 50.0...60.0)
        return layoutContext.stretchedSize(withScrollAxisExtent: extent)
    }
}


// MARK: - List Builder


class GenericListViewController: UIViewController {
    
    class Object: ListDiffable, ListCellSizeCacheIdentifiable {
        let value: Int
        
        init(value: Int) {
            self.value = value
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            value as NSObjectProtocol
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            true
        }
    }

    class Cell: UICollectionViewCell, ListCellSizeProviding {
        
        let textLabel = UILabel(textAlignment: .center)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.addSubview(textLabel)
            textLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(uniformValue: .XUI.spacing5))
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private var objects: [Object] = (0..<50).map { Object(value: $0) }
    
//    private let listConfiguration = GenericListBuilder.Configuration { object, index, sectionContext in
//        Cell.self
//        
//    } cellConfigurator: { cell, object, index, sectionContext in
//        let cell = cell as! Cell
//        cell.textLabel.text = "Item: \((object as! Object).value)"
//        
//    } itemCountProvider: { object, sectionContext in
//        1
//        
//    } cellSizeProvider: { object, index, sectionContext in
//        .XUI.automaticDimension
//        
//    } sectionStyleProvider: { object in
//        .init(
//            inset: .init(uniformValue: .XUI.spacing2),
//            backgroundConfiguration: .overlay()
//        )
//        
//    }
    
    private let listConfiguration = GenericListBuilder.Configuration.single(of: Cell.self) { cell, sectionContext in
        cell.textLabel.text = "Item: \((sectionContext.object as! Object).value)"
        
    } sectionStyleProvider: { object in
        .init(
            inset: .init(uniformValue: .XUI.spacing2),
            backgroundConfiguration: .overlay()
        )
    }

    
    private lazy var listBuilder = GenericListBuilder(objects: objects, configuration: listConfiguration)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        listBuilder.addList(to: self)
    }
    
}


class BindingListViewController: UIViewController {
    
    class Object: ListDiffable, ListCellSizeCacheIdentifiable {
        let value: Int
        
        init(value: Int) {
            self.value = value
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            value as NSObjectProtocol
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            true
        }
    }

    class ViewModel: ListDiffable, ListCellSizeCacheIdentifiable {
        let valueText: String
        
        private let object: Object
        
        init(object: Object) {
            self.object = object
            self.valueText = "Item \(object.value)"
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            object.diffIdentifier()
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            guard let object = object as? ViewModel else { return false }
            
            return object.valueText == valueText
        }
    }

    
    class Cell: UICollectionViewCell, ListBindable, ListCellSizeProviding {
        
        let textLabel = UILabel(textAlignment: .center)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.addSubview(textLabel)
            textLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(uniformValue: .XUI.spacing5))
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func bindViewModel(_ viewModel: Any) {
            guard let viewModel = viewModel as? ViewModel else {
                return
            }
            
            textLabel.text = viewModel.valueText
        }
        
        var cellSizeOptions: ListCellSizeOptions {
            [.compress, .configureCell, .cache]
        }
    }
    
    private var objects: [Object] = (0..<50).map { Object(value: $0) }
    
    private let listConfiguration = BindingListBuilder.Configuration.single(of: Cell.self, scrollDirection: .horizontal) { sectionContext in
        ViewModel(object: sectionContext.object as! Object)
        
    } sectionStyleProvider: { object in
        .init(
            inset: .init(uniformValue: .XUI.spacing2),
            backgroundConfiguration: .overlay()
        )
    }

    private lazy var listBuilder = BindingListBuilder(objects: objects, configuration: listConfiguration)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        listBuilder.addList(to: self)
    }
}
