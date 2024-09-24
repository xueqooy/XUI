//
//  DropdownMenuContentView.swift
//  LLPUI
//
//  Created by xueqooy on 2024/5/21.
//

import UIKit
import IGListDiffKit

class DropdownMenuContentView: UIView {
    
    private static let customSpacingAfterTitle: CGFloat = .LLPUI.spacing2
    
    typealias Action = DropdownMenu.Action
    
    @MainActor var objects: [ListDiffable] {
        set { listBuilder.objects = newValue }
        get { listBuilder.objects }
    }
    
    private lazy var listBuilder: GenericListBuilder = GenericListBuilder(configuration: .single(of: DropdownMenuCell.self) { [weak self] cell, sectionContext in
        
        let action = sectionContext.object as! Action
        cell.update(withAction: action, style: self?.dropdownMenu?.preference.style ?? .plain)
        
    } cellSizeProvider: { [weak self] sectionContext in
        .init(width: sectionContext.sectionContainerWidth, height: self?.dropdownMenu?.preference.style.rowHeight ?? 0)
        
    } itemDidSelectHandler: { [weak self] sectionContext in
        let action = sectionContext.object as! Action
        action.handler(action)
        
        if !action.attributes.contains(.keepsMenuPresented), let self {
            self.dropdownMenu?.hide()
        }
    })
        
    private weak var dropdownMenu: DropdownMenu?
    
    private lazy var titleLabel = UILabel(text: dropdownMenu?.title, textColor: Colors.title.withAlphaComponent(0.9), font: dropdownMenu?.preference.style.menuTitleFont ?? Fonts.body2Bold, textAlignment: .center)
    
    init(dropDownMenu: DropdownMenu) {
        self.dropdownMenu = dropDownMenu
            
        super.init(frame: .zero)
                
        let stackView = VStackView {
            if dropDownMenu.title?.isEmpty == false {
                titleLabel
                VSpacerView(Self.customSpacingAfterTitle)
            }
            
            listBuilder.listController.listView
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DropdownMenuContentView {
    
    static func calculateContentSize(with actions: [Action], title: String?, preference: DropdownMenu.Preference) -> CGSize {
        let miniumWidth: CGFloat = preference.minimumContentWidth

        let menuTitleSize = title?.preferredSize(for: preference.style.menuTitleFont, width: preference.maximumContentWidth, numberOfLines: 1) ?? .zero
                
        let actionTitleBoundingWidth = preference.maximumContentWidth - preference.style.actionTitleHorizontalInset * 2
        
        var actionListWidth = actions.map { $0.title.preferredSize(for: preference.style.actionTitleFont, width: actionTitleBoundingWidth, numberOfLines: DropdownMenuCell.titleLines).width }.max() ?? 0
        actionListWidth += preference.style.actionTitleHorizontalInset * 2
        
        let actionListHeight = CGFloat(actions.count) * preference.style.rowHeight
        
        return CGSize(width: max(miniumWidth, max(actionListWidth, menuTitleSize.width)), height: actionListHeight + menuTitleSize.height + (menuTitleSize.height > 0 ? Self.customSpacingAfterTitle : 0))
    }
}
