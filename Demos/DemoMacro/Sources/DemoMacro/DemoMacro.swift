// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

@attached(member, names: named(title), named(viewController))
public macro DemoEnum() = #externalMacro(module: "Macros", type: "DemoEnumMacro")
