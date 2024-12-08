//
//  Stack+DSL.swift
//  XUI
//
//  Created by xueqooy on 2023/11/3.
//

import UIKit

@resultBuilder
public struct ViewBuilder {
    public typealias Expression = UIView
    public typealias Component = [UIView]
    
    public static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }
    
    public static func buildBlock(_ components: Component...) -> Component {
        return components.flatMap { $0 }
    }
    
    public static func buildBlock(_ components: Expression...) -> Component {
        return components.map { $0 }
    }
    
    public static func buildOptional(_ component: Component?) -> Component {
        return component ?? []
    }
    
    public static func buildEither(first component: Component) -> Component {
        return component
    }
    
    public static func buildEither(second component: Component) -> Component {
        return component
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        Array(components.joined())
    }
    
    public static func buildLimitedAvailability(_ component: Component) -> Component {
        component
    }
}
