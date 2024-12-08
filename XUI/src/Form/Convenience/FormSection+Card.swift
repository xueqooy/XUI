//
//  FormSection+Card.swift
//  CombineCocoa
//
//  Created by xueqooy on 2024/1/11.
//

import UIKit
import XKit

public extension FormSection {
    
    static func card(contentInset: Insets = .directional(uniformValue: .XUI.spacing5), itemSpacing: CGFloat = 0, automaticallyUpdatesVisibility: Bool = true, @ArrayBuilder<FormComponent> components: () -> [FormComponent]
    ) -> FormSection {
        FormSection(backgroundConfiguration: .overlay(), contentInset: contentInset, itemSpacing: itemSpacing, automaticallyUpdatesVisibility: automaticallyUpdatesVisibility, components: components)
    }
}
