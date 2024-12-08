//
//  ActionBarDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2024/3/28.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import XUI

class ActionBarDemoController: DemoController {
    
    enum Action {
        case like, comment, share, reply
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.background1
        
        addTitle("Center Alignment")
        addActionRow(alignment: .center, actions: [.like])
        addActionRow(alignment: .center, actions: [.like], debug: true)
        
        addActionRow(alignment: .center, actions: [.like, .comment])
        addActionRow(alignment: .center, actions: [.like, .comment], debug: true)
        
        addActionRow(alignment: .center, actions: [.like, .comment, .share])
        addActionRow(alignment: .center, actions: [.like, .comment, .share], debug: true)
        
        addSpacer()
        
        addTitle("Leading Alignment")
        addActionRow(alignment: .leading, actions: [.like])
        addActionRow(alignment: .leading, actions: [.like], debug: true)
        
        addActionRow(alignment: .leading, actions: [.like, .reply])
        addActionRow(alignment: .leading, actions: [.like, .reply], debug: true)
        
        addActionRow(alignment: .leading, actions: [.like, .reply, .share])
        addActionRow(alignment: .leading, actions: [.like, .reply, .share], debug: true)
    }
    
    private func addActionRow(alignment: ActionBar.Alignment, actions: [Action], debug: Bool = false) {
        let containerView = BackgroundView(configuration: .overlay())
        containerView.isUserInteractionEnabled = true
        
        let actionView = ActionBar(alignment: alignment, items: actions.map { makeActionBarItem(for: $0) }, debug: debug)
        
        containerView.addSubview(actionView)
        actionView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: .XUI.spacing5, bottom: 0, right: .XUI.spacing5))
        }
        
        addRow(containerView, height: 42, alignment: .fill)
    }
    
    private func makeActionBarItem(for action: Action) -> ActionBarItem {
        switch action {
        case .like:
            var liked = false
            return .init(title: Strings.like(0), image: Icons.likeDeactive) { item, sourceView in
                liked.toggle()
                
                item.performBatchStateUpdates {
                    $0.title = liked ? Strings.like(1) : Strings.like(0)
                    $0.image = liked ? Icons.likeActive : Icons.likeDeactive
                }
            }
            
        case .comment:
            var count: Int = 0
            return .init(title: Strings.comment(0), image: Icons.comment) { item, sourceView in
                count += 1
                
                item.title = Strings.comment(count)
            }
            
        case .reply:
            var count: Int = 0
            return .init(title: Strings.reply(0), image: Icons.comment) { item, sourceView in
                count += 1
                
                item.title = Strings.reply(count)
            }
            
        case .share:
            return .init(title: Strings.share, image: Icons.share) { [weak self] item, sourceView in
                guard let self = self else { return }

                var configuration = Popover.Configuration()
                configuration.dismissMode = .tapOnSuperview
                configuration.preferredDirection = .down

                let popover = Popover(configuration: configuration)

                let label = UILabel(text: "Share", textColor: Colors.title, font: Fonts.h6)
                popover.show(label, in: self.view, from: sourceView)
            }
        }
    }
}
