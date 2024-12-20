//
//  EntityBadgeContainerView.swift
//  XUI
//
//  Created by xueqooy on 2024/5/31.
//

import IGListDiffKit
import IGListKit
import IGListSwiftKit
import UIKit
import XKit
import XUI

public class EntityBadgeContainerView: UIView {
    public enum TapTarget {
        case entity(Entity)
        case viewAll([Entity])
    }

    @EquatableState
    public var entities: [Entity] = [] {
        didSet {
            var objects: [ListDiffable]
            if entities.count > maxDisplayCount {
                objects = Array(entities.prefix(maxDisplayCount))
                objects.append(ViewAllEntitiesViewModel(additionalCount: entities.count - maxDisplayCount, height: cancellable ? 22 : 14))

            } else {
                objects = entities
            }

            listBuilder.objects = objects
        }
    }

    public var contentInset: UIEdgeInsets {
        set {
            listBuilder.listController.listView.contentInset = newValue
        }
        get {
            listBuilder.listController.listView.contentInset
        }
    }

    private let maxDisplayCount: Int

    public var tapAction: ((EntityBadgeContainerView, TapTarget) -> Void)?

    private lazy var listBuilder: GenericListBuilder = {
        let configuration: GenericListBuilder.Configuration = .init { [weak self] _, sectionContext in

            let cancellable = self?.cancellable == true

            if sectionContext.object is PersonaEntity {
                return cancellable ? CancellableEntityBadgeCell<PersonaBadgeView>.self : EntityBadgeCell<PersonaBadgeView>.self

            } else if sectionContext.object is GroupEntity {
                return cancellable ? CancellableEntityBadgeCell<GroupBadgeView>.self : EntityBadgeCell<GroupBadgeView>.self

            } else if sectionContext.object is ViewAllEntitiesViewModel {
                return ViewAllEntitiesCell.self
            } else {
                fatalError("Unsupported type")
            }

        } cellConfigurator: { [weak self] cell, _, sectionContext in

            let object = sectionContext.object

            if var cancellableGroupBadgeCell = cell as? EntityBadgeCancellable, let self {
                cancellableGroupBadgeCell.cancelHandler = { [weak self] in
                    let entity = object as! Entity

                    self?.entities.removeAll { $0.id.entityIdentifier == entity.id.entityIdentifier }
                }
            }

            return (cell as! ListBindable).bindViewModel(sectionContext.object)

        } sectionStyleProvider: { _ in

            .init(inset: .init(top: 0, left: .XUI.spacing1, bottom: 6, right: .XUI.spacing1))

        } itemDidSelectHandler: { [weak self] _, sectionContext in
            guard let self else {
                return
            }

            if let entity = sectionContext.object as? Entity {
                self.tapAction?(self, .entity(entity))

            } else if sectionContext.object is ViewAllEntitiesViewModel {
                self.tapAction?(self, .viewAll(self.entities))
            }
        }

        let listBuilder = GenericListBuilder(configuration: configuration)
        listBuilder.listController.listView.automaticallyUpdatesIntrinsicContentSize = true

        return listBuilder
    }()

    private let cancellable: Bool

    public init(maxDisplayCount: Int = .max, cancellable: Bool = false, entities: [Entity] = [], tapAction: ((EntityBadgeContainerView, TapTarget) -> Void)? = nil) {
        self.maxDisplayCount = max(0, maxDisplayCount)
        self.cancellable = cancellable
        self.tapAction = tapAction

        super.init(frame: .zero)

        let listView = listBuilder.listController.listView
        listView.alwaysBounceVertical = false

        addSubview(listView)
        listView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        defer {
            self.entities = entities
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
