//
//  ActionBarItem.swift
//  XUI
//
//  Created by xueqooy on 2024/3/28.
//

import UIKit
import XKit

public class ActionBarItem: StateObservableObject {
    public typealias ActionBarItemHandler = (_ item: ActionBarItem, _ sourceView: UIView) -> Void

    @EquatableState
    public var title: String

    @EquatableState
    public var image: UIImage?

    @EquatableState
    public var titleColor: UIColor

    @EquatableState
    public var isHidden: Bool

    var handler: ActionBarItemHandler

    public init(title: String = "", image: UIImage? = nil, titleColor: UIColor = Colors.title, isHidden: Bool = false, handler: @escaping ActionBarItemHandler) {
        self.title = title
        self.image = image
        self.titleColor = titleColor
        self.isHidden = isHidden
        self.handler = handler
    }
}
