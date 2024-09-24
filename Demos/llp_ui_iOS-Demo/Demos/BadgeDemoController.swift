//
//  BadgeDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/2/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI

class BadgeDemoController: DemoController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationItem1 = UIBarButtonItem(image: Icons.notification, style: .plain, target: nil, action: nil)
        let navigationItem2 = UIBarButtonItem(image: Icons.notification, style: .plain, target: nil, action: nil)
                
        navigationItem1.viewPublisher
            .sink { view in
                if let view = view {
                    let badge = BadgeView(color: Colors.orange)
                    badge.addToView(view, offset: .init(horizontal: -15, vertical: 15))
                }
            }
            .store(in: &cancellables)
        
        navigationItem2.viewPublisher
            .sink { view in
                if let view = view {
                    let badge = BadgeView(color: Colors.orange, valueColor: .white, value: "8")
                    badge.addToView(view, offset: .init(horizontal: -12, vertical: 12))
                }
            }
            .store(in: &cancellables)
        
        navigationItem.rightBarButtonItems = [navigationItem2, navigationItem1]
        
        
        let values = ["", "8", "88", "New"]
        let toolItem1 = UIBarButtonItem(image: Icons.calendar, style: .plain, target: nil, action: nil)
        let toolItem2 = UIBarButtonItem(image: Icons.camera, style: .plain, target: nil, action: nil)
        let toolItem3 = UIBarButtonItem(image: Icons.search, style: .plain, target: nil, action: nil)
        let toolItem4 = UIBarButtonItem(image: Icons.notification, style: .plain, target: nil, action: nil)
        
        [toolItem1, toolItem2, toolItem3, toolItem4].enumerated()
            .forEach { (index, item) in
                item.viewPublisher
                    .sink { view in
                        guard let view = view else { return }
                        
                        let badge = BadgeView(value: values[index])
                        badge.addToView(view, offset: .init(horizontal: -5, vertical: 12))
                    }
                    .store(in: &cancellables)
            }
        
        self.toolbarItems = [.flexibleSpace, toolItem1, .flexibleSpace, toolItem2, .flexibleSpace, toolItem3, .flexibleSpace, toolItem4, .flexibleSpace]
        
        
        let label1 = UILabel()
        label1.text = "Dot Badge"
        label1.backgroundColor = .lightGray.withAlphaComponent(0.2)
        label1.textColor = Colors.title
        label1.font = Fonts.body1Bold
        
        let label2 = UILabel()
        label2.text = "Number Badge"
        label2.backgroundColor = .lightGray.withAlphaComponent(0.2)
        label2.textColor = Colors.title
        label2.font = Fonts.body1Bold
        
        let label3 = UILabel()
        label3.text = "Text Badge"
        label3.backgroundColor = .lightGray.withAlphaComponent(0.2)
        label3.textColor = Colors.title
        label3.font = Fonts.body1Bold
        
        let label1Badge = BadgeView()
        label1Badge.addToView(label1)
        
        let label2Badge = BadgeView()
        label2Badge.value = "8"
        label2Badge.addToView(label2, offset: UIOffset(horizontal: 5, vertical: 0))
        
        let label3Badge = BadgeView()
        label3Badge.value = "New"
        label3Badge.addToView(label3, offset: UIOffset(horizontal: 10, vertical: 0))
        
        addRow(BadgeView())
        addRow(BadgeView(value: "8"))
        addRow(BadgeView(value: "88"))
        addRow(BadgeView(value: "New"))
        addRow(label1)
        addRow(label2)
        addRow(label3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.toolbar.tintColor = Colors.teal
        navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isToolbarHidden = true
    }
}
