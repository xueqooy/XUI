//
//  ChangeLog.swift
//  XUI_Example
//
//  Created by xueqooy on 2023/9/5.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import XUI

class ChangeLog {
    struct Item {
        let version: String
        let summary: RichText
        let date: String
    }

    enum Tag: String {
        case feature, bugfix, optimize

        var color: UIColor {
            switch self {
            case .feature:
                return Colors.green
            case .bugfix:
                return Colors.red
            case .optimize:
                return Colors.extraLightTeal
            }
        }
    }

    static var latestVersion: String {
        items.first?.version ?? ""
    }

    static let items: [Item] = [
        .init(
            version: "v1.0.0",
            summary: """
            \(tag(.feature)) Add \(highlight("FilterSortActionView", action: Actions.showFilterSortActionDemo))
            """,
            date: "2023/9/5"
        ),

        .init(
            version: "v1.1.0",
            summary: """
            \(tag(.feature)) Add \(highlight("EmptyView", action: Actions.showEmptyDemo))
            """,
            date: "2023/9/5"
        ),

        .init(
            version: "v1.1.1",
            summary: """
            \(tag(.bugfix)) Fix the issue of \(highlight("ListController", action: Actions.showListDemo)) being unable to load \(bold("Objects")) in some cases
            """,
            date: "2023/9/6"
        ),

        .init(
            version: "v1.2.0",
            summary: """
            \(tag(.feature)) Add \(bold("switch")) style to \(highlight("OptionControl", action: Actions.showOptionControlDemo))

            \(tag(.feature)) Add \(bold("refresh")) capability to the \(highlight("List", action: Actions.showListDemo))
            """,
            date: "2023/9/11"
        ),

        .init(
            version: "v1.2.1",
            summary: """
            \(tag(.feature)) Add \(bold("view")) hook to \(bold("UIBarItem")) -> \(highlight("Demo", action: Actions.showBadgeDemo))
            """,
            date: "2023/9/11"
        ),

        .init(
            version: "v1.2.2",
            summary: """
            \(tag(.optimize)) Enable \(highlight("BadgeView", action: Actions.showBadgeDemo)) to support any text type, not just numbers
            """,
            date: "2023/9/11"
        ),

        .init(
            version: "v1.3.0",
            summary: """
            \(tag(.feature)) Add \(highlight("AvatarView", action: Actions.showAvatarDemo))

            \(tag(.feature)) Add \(highlight("TripleImageView", action: Actions.showTripleImageDemo))

            \(tag(.feature)) Add \(highlight("HighlightableTapGestureRecognizer"))
            """,
            date: "2023/9/13"
        ),

        .init(
            version: "v1.3.1",
            summary: """
            \(tag(.bugfix)) Use \(bold("zero")) instead of \(bold(".greatestFiniteMagnitude")) to minimize the value of height calculation in certain scenarios for \(highlight("ListCellSizeManager"))
            """,
            date: "2023/9/13"
        ),

        .init(
            version: "v1.3.2",
            summary: """
            \(tag(.feature)) Add \(highlight("ListBindingCell"))

            \(tag(.feature)) Add \(highlight("isDescendantOfDummyCell")) to \(bold("UIView"))
            """,
            date: "2023/9/14"
        ),

        .init(
            version: "v1.4.0",
            summary: """
            \(tag(.feature)) Add \(highlight("MediaView", action: Actions.showAttachmentDemo))
            """,
            date: "2023/9/14"
        ),
    ].reversed()

    private static func tag(_ tag: Tag) -> RichText {
        "\("[\(tag.rawValue.capitalized)]\n", .foreground(tag.color), .font(Fonts.body2Bold))"
    }

    private static func bold(_ content: String) -> RichText {
        "\(content, .font(Fonts.font(ofSize: 14, weight: .bold)), .foreground(.black))" as RichText
    }

    private static func highlight(_ content: String, action: (() -> Void)? = nil) -> RichText {
        var result = "\(content, .foreground(Colors.teal))" as RichText
        if let action = action {
            result.addStyles(.underline(.single))
            result.addStyles(.action([.foreground(Colors.teal)]) { _ in
                action()
            })
        }
        return result
    }

    static func output() -> RichText {
        items.reduce(into: RichText("")) { partialResult, item in
            partialResult += "\(item.version, .foreground(Colors.title), .font(Fonts.h6), .paragraph(.alignment(.left)))" as RichText
            partialResult += "\n" as RichText
            partialResult += "\(supplement: item.summary, .font(Fonts.body1), .foreground(Colors.bodyText1))" as RichText
            partialResult += "\n" as RichText
            partialResult += "\(item.date, .font(Fonts.caption), .foreground(Colors.bodyText1), .paragraph(.alignment(.right)))" as RichText
            partialResult += "\n\n\n" as RichText
        }
    }
}

private class Actions {
    static func showFilterSortActionDemo() {
        showDemo(.FilterSortAction)
    }

    static func showEmptyDemo() {
        showDemo(.Empty)
    }

    static func showOptionControlDemo() {
        showDemo(.OptionControl)
    }

    static func showListDemo() {
        showDemo(.List)
    }

    static func showBadgeDemo() {
        showDemo(.Badge)
    }

    static func showTripleImageDemo() {
        showDemo(.TripleImage)
    }

    static func showAvatarDemo() {
        showDemo(.Avatar)
    }

    static func showAttachmentDemo() {
        showDemo(.Media)
    }

    private static func showDemo(_ demo: Demo) {
        guard let mainController = (UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController)?.viewControllers.first as? MainController else {
            return
        }
        mainController.showDemo(demo)
    }
}

class ChangeLogController: UIViewController {
    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: 修复TextView无法滚动的问题，点击高亮后又可以滚动了，

        textView.isSelectable = false
        textView.isEditable = false

        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(500)
            make.edges.equalToSuperview()
        }

        textView.addChecking(.action, action: .init(handler: { [weak self] _ in
            self?.dismiss(animated: false)
        }))

        textView.richText = ChangeLog.output()
    }

    func show(from barButtonItem: UIBarButtonItem) {
        preferredContentSize = .init(width: UIApplication.shared.keyWindows.first!.bounds.width / 2, height: 0)

        let drawer = DrawerController(barButtonItem: barButtonItem, configuration: .init(presentationDirection: .up, resizingBehavior: .dismissOrExpand))
        drawer.contentScrollView = textView
        drawer.contentController = self

        UIApplication.shared.keyWindows.first?.rootViewController?.present(drawer, animated: true)
    }
}
