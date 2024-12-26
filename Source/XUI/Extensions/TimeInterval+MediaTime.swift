//
//  TimeInterval+MediaTime.swift
//  XUI
//
//  Created by xueqooy on 2024/12/2.
//

import Foundation

public extension TimeInterval {
    var mediaTimeString: String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60
        let remainingSeconds = Int(self) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
}
