//
//  CoachmarkDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/8/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import LLPUI
import LLPUtils

class CoachmarkDemoController: DemoController {
    
    let titleView = UILabel(text: "Coachmark", textColor: Colors.title, font: Fonts.body1Bold, textAlignment: .center)
    
    let avatarView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let nameLabel = UILabel(text: "Xueqooy", textColor: Colors.title, font: Fonts.h6, textAlignment: .center)
    
    let descriptionField = MultilineInputField(label: "Description", placeholder: "Input description")
    
    let coachmarkController = CoachmarkController()
    
    private lazy var myTabBarController = MyTabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = titleView
        
        coachmarkController.dataSource = self
        
        addRow(avatarView)
        addRow(nameLabel)
        addRow(descriptionField, alignment: .fill)
        addRow(Button(designStyle: .primary, title: "Start", touchUpInsideAction: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.coachmarkController.start()
        }))
        
        avatarView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
    }
    
    private func showCoachmark(for viewOrBarItemOrNil: Any?, index: Int, instruction: String, cornerStyle: CornerStyle = .fixed(.LLPUI.smallCornerRadius), insets: UIEdgeInsets = .init(uniformValue: -10), delay: TimeInterval = 0, completionHandler: @escaping (Coachmark?) -> Void) {
        let contentView = CoachmarkGenericContentView(currentStep: index, totalSteps: 7, instruction: instruction, controller: self.coachmarkController)
        
        let rect: CGRect
        if let anchorView = viewOrBarItemOrNil as? UIView {
            rect = coachmarkController.coachmarkRect(for: anchorView, insets: insets)
        } else if let barButtonItem = viewOrBarItemOrNil as? UIBarButtonItem {
            rect = coachmarkController.coachmarkRect(for: barButtonItem, insets: insets)
        } else if let tabBarItem = viewOrBarItemOrNil as? UITabBarItem {
            rect = coachmarkController.coachmarkRect(for: tabBarItem, insets: insets)
        } else {
            rect = .zero
        }
        
        let coachmark = Coachmark(rect: rect, cutoutCornerStyle: cornerStyle, contentView: contentView)
        
        if delay == 0 {
            completionHandler(coachmark)
        } else {
            Queue.main.execute(.delay(delay)) {
                completionHandler(coachmark)
            }
        }
    }
}

extension CoachmarkDemoController: CoachmarkControllerDataSource {
    func coachmarkController(_ controller: CoachmarkController, requestCoachmarkAt index: Int, completionHandler: @escaping (Coachmark?) -> Void) {
        switch index {
        case 0:
            showCoachmark(for: titleView, index: index, instruction: "Create walkthroughs and guided coach marks in a simple way.", completionHandler: completionHandler)
        case 1:
            showCoachmark(for: avatarView, index: index, instruction: "This is a avatar, you can set it up by uploading a local image", cornerStyle: .capsule, completionHandler: completionHandler)
        case 2:
            showCoachmark(for: nameLabel, index: index, instruction: "Your name is displayed here", completionHandler: completionHandler)
        case 3:
            showCoachmark(for: descriptionField, index: index, instruction: "You can enter any description about yourself, such as interests and hobbies", completionHandler: completionHandler)
        case 4:
            if let _ = self.myTabBarController.navigationController {
                self.showCoachmark(for: self.myTabBarController.tabBarItems.first, index: index, instruction: "Show your location here", insets: .init(top: -10, left: 30, bottom: -10, right: 30), completionHandler: completionHandler)
            } else {
                let navigationController = UINavigationController(rootViewController: myTabBarController)
                present(navigationController, animated: true) {
                    self.showCoachmark(for: self.myTabBarController.tabBarItems.first, index: index, instruction: "Show your location here", insets: .init(top: -10, left: 30, bottom: -10, right: 30), completionHandler: completionHandler)
                }
            }
           
        case 5:
            self.showCoachmark(for: self.myTabBarController.tabBarItems[1], index: index, instruction: "Show today's weather situation here", insets: .init(top: -10, left: 30, bottom: -10, right: 30), completionHandler: completionHandler)
        case 6:
            self.showCoachmark(for: self.myTabBarController.closeItem, index: index, instruction: "Click the close button to close", insets: .init(top: 0, left: -8, bottom: 0, right: 0), completionHandler: completionHandler)
        default:
            completionHandler(nil)
            break
        }
    }
}


private class MyTabBarController: UITabBarController {
    lazy var closeItem: UIBarButtonItem = .init(title: "Close", style: .plain, target: self, action: #selector(closeAction))
    
    let tabBarItems: [UITabBarItem] = {
        [
            .init(title: "Location", image: UIImage(systemName: "map.fill"), tag: 0),
            .init(title: "Weather", image: UIImage(systemName: "sun.min.fill"), tag: 1)
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let locationViewControlelr = UIViewController()
        locationViewControlelr.tabBarItem = tabBarItems[0]
        
        let weatherViewController = UIViewController()
        weatherViewController.tabBarItem = tabBarItems[1]
        
        setViewControllers([locationViewControlelr, weatherViewController], animated: false)
                
        navigationItem.rightBarButtonItem = closeItem
    }
    
    @objc func closeAction() {
        navigationController?.dismiss(animated: true)
    }
}
