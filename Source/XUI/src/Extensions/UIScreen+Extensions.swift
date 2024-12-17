//
//  UIScreen+Extensions.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/10/20.
//

import UIKit

public extension UIScreen {
    var isSplitScreenIPad: Bool {
        Device.current.isPad && UIScreen.main.bounds.width != UIScreen.main.applicationSize.width
    }
    
    // The size returned by the applicationFrame on the iPad is smaller than the actual size of the window. This difference is reflected in the origin, so the correct size can be obtained by using the origin+size correction.
    var applicationSize: CGSize {
        let applicationFrame = self.applicationFrame
        
        var applicationSize = CGSize(width: applicationFrame.maxX, height: applicationFrame.maxY)
        
        if applicationSize == .zero {
            //The measured MacCatalystApp passed [UIScreen mainScreen] The applicationFrame can't get the size. Here's how to protect it
            if let window = UIApplication.shared.delegate?.window {
                applicationSize = window?.bounds.size ?? .zero
            } else {
                applicationSize = UIWindow().bounds.size
            }
        }
        
        return applicationSize
    }
    
    var devicePixel: CGFloat {
        1 / scale
    }
}
