//
//  URL+RandomImage.swift
//  XUI_Example
//
//  Created by xueqooy on 2023/9/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

extension URL {
    static func randomImageURL(width: Int = .random(in: 100 ... 200), height: Int = .random(in: 100 ... 200)) -> URL {
        URL(string: "https://picsum.photos/\(width)/\(height)")!
    }
}
