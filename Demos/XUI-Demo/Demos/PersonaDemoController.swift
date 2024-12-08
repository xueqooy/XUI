//
//  PersonaDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2024/1/4.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import XUI

class PersonaDemoController: DemoController {
    
    private var showsAvatar: Bool = true {
        didSet {
            updatePersonaView()
        }
    }
    
    private var showsTitle: Bool = true {
        didSet {
            updatePersonaView()
        }
    }
    
    private var showsSubtitle: Bool = true {
        didSet {
            updatePersonaView()
        }
    }
    
    private let personaView = PersonaView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        addRow(
            createLabelAndSwitchRow(labelText: "Avatar", root: self, keyPath: \.showsAvatar)
        )
        addRow(
            createLabelAndSwitchRow(labelText: "Title", root: self, keyPath: \.showsTitle)
        )
        addRow(
            createLabelAndSwitchRow(labelText: "Subtitle", root: self, keyPath: \.showsSubtitle)
        )
        
        addSeparator()
    
        addRow(personaView)
        
        updatePersonaView()
    }
    
    private func updatePersonaView() {
        personaView.update { configuration in
            if showsAvatar {
                let avatarURLConfiguration = AvatarURLConfiguration(preferredURL: .randomImageURL(width: 80, height: 80))
                configuration.avatarURLConfiguration = avatarURLConfiguration
            } else {
                configuration.avatarURLConfiguration = nil
            }
            
            if showsTitle {
                configuration.title = .random(10..<50)
            } else {
                configuration.clearTitle()
            }
            
            if showsSubtitle {
                configuration.subtitle = .random(10..<50)
            } else {
                configuration.clearSubtitle()
            }            
        }
    }
}
