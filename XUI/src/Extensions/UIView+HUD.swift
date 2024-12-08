//
//  UIView+HUD.swift
//  XUI
//
//  Created by xueqooy on 2024/3/15.
//

import UIKit
import XKit

private let hudAssociation = Association<HUD>()

public extension UIView {
    
    var hud: HUD {
        var hud = hudAssociation[self]
        
        if hud == nil {
            hud = HUD()
            hudAssociation[self] = hud
        }
        
        return hud!
    }
    
    func showHUD(_ contentType: HUD.ContentType, hideAfter delay: TimeInterval = 0, interactionEnabled: Bool = false, action: HUD.Action? = nil) {
        hud.show(contentType, in: self, hideAfter: delay, interactionEnabled: interactionEnabled, action: action)
    }
    
    func hideHUD() {
        hud.hide()
        
        hudAssociation[self] = nil
    }
    
    
}
