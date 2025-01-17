//
//  ListSectionBackgroundDecorationViewLayoutAttributes.swift
//  XUI
//
//  Created by xueqooy on 2023/8/15.
//

import UIKit
import XUI

class ListSectionBackgroundDecorationViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var configuration: BackgroundConfiguration = .init()

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ListSectionBackgroundDecorationViewLayoutAttributes
        copy.configuration = configuration
        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ListSectionBackgroundDecorationViewLayoutAttributes else {
            return false
        }

        if configuration != object.configuration {
            return false
        }

        return super.isEqual(object)
    }
}
