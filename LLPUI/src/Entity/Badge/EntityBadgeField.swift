//
//  EntityBadgeField.swift
//  LLPUI
//
//  Created by xueqooy on 2024/7/1.
//

import UIKit
import LLPUtils
import Combine

public class EntityBadgeField: Field {
    
    @EquatableState
    public var entities: [Entity] = [] {
        didSet {
            guard entities != oldValue else { return }
            
            placeholderLabel.isHidden = !entities.isEmpty
            
            badgeContainerView.entities = entities
        }
    }
    
    public var placeholder: String? {
        set {
            placeholderLabel.text = newValue
        }
        get {
            placeholderLabel.text
        }
    }
    
    public override var fieldState: FieldState {
        if isEnabled {
            if isSelectActive {
                return .active
            } else {
                return .normal
            }
        } else {
            return .disabled
        }
    }
    
    public var selectionDataSource: EntityListDataSource = [] {
        didSet {
            currentListController?.dataSource = selectionDataSource
        }
    }
    
    
    private var isSelectActive: Bool = false {
        didSet {
            if oldValue == isSelectActive {
                return
            }
            
            stateDidChange()
        }
    }
    
    private lazy var badgeContainerView: EntityBadgeContainerView = {
        let view = EntityBadgeContainerView(cancellable: true)
        
        view.contentInset = .init(top: 8, left: 0, bottom: 2, right: 0)
        
        let minimumHeightConstraint = view.heightAnchor.constraint(greaterThanOrEqualToConstant: 38)
        minimumHeightConstraint.priority = .defaultHigh
        minimumHeightConstraint.isActive = true
        
        view.heightAnchor.constraint(lessThanOrEqualToConstant: 190).isActive = true
        
        badgeEntitiesSubscription = view.$entities.didChange
            .sink { [weak self] in
                guard let self else { return }
                                
                self.entities = $0
            }
        
        view.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: .LLPUI.spacing1, bottom: 0, right: .LLPUI.spacing1))
        }
        
        return view
    }()
    
    private lazy var placeholderLabel = UILabel(textStyleConfiguration: .placeholder)
    
    private lazy var dropdownImageView = UIImageView(image: Icons.dropdown, contentMode: .scaleAspectFit)
        
    private var badgeEntitiesSubscription: AnyCancellable?
            
    private weak var currentListController: EntityListController?
    
    public init() {
        super.init()
        
        initialize()
    }
    
    public convenience init(entities: [Entity] = [], selectionDataSource: EntityListDataSource = [], label: String? = nil, placeholder: String? = nil) {
        self.init()
        
        self.selectionDataSource = selectionDataSource
        self.label = label
        self.placeholder = placeholder
        
        defer {
            self.entities = entities
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func makeContentView() -> UIView {
        badgeContainerView
    }
    
    public override func stateDidChange() {
        super.stateDidChange()
        
        dropdownImageView.tintColor = fieldState == .disabled ? Colors.disableText : Colors.vibrantTeal
    }
    
    private func initialize() {
        contentInset = .directional(top: 1, leading: .LLPUI.spacing3, bottom: 1, trailing: .LLPUI.spacing4)
        
        boxStackView.addArrangedSubview(dropdownImageView)
        dropdownImageView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Self.boxTapped))
        tapGestureRecognizer.delegate = self
        boxStackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func boxTapped() {
        guard currentListController == nil, let presentingViewController = findContainingViewController() ?? UIApplication.shared.keyWindows.first?.rootViewController else { return }
                
        let drawer = DrawerController(sourceView: self, configuration: .init(resizingBehavior: .dismissOrExpand))
        
        let listController = EntityListController(action: [.multiSelect, .search], dataSource: selectionDataSource, selection: entities) { [weak self, weak drawer] in
            self?.entities = $0
            drawer?.dismiss(animated: true)
        }
        listController.title = label
        listController.preferredContentSize = CGSize(width: 350, height: 500)

        drawer.contentController = listController
        drawer.onDismissCompleted = { [weak self] in
            self?.isSelectActive = false
            self?.currentListController = nil
        }
        
        self.isSelectActive = true
        
        presentingViewController.present(drawer, animated: true)
        
        currentListController = listController
    }
    
}

extension EntityBadgeField: UIGestureRecognizerDelegate {
    // If tapped on UIControl, respond to UIControl action; otherwise, respond to tap gesture
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view is UIControl {
            return false
        }
        
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
