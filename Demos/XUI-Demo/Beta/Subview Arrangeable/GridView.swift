//
//  GridView.swift
//  EDUI
//
//  Created by 🌊 薛 on 2022/9/20.
//

import UIKit

public class GridView: SubviewArrangeableView {
    public enum RowLayout: Equatable {
        case filled
        case ratio(_ value: CGFloat) // ratio to column width
        case fixed(_ value: CGFloat)
        case divide(_ value: Int)
    }

    public var columnCount: Int {
        didSet {
            if oldValue != columnCount {
                setNeedsLayout()
            }
        }
    }

    public var rowLayout: GridView.RowLayout {
        didSet {
            if oldValue != rowLayout {
                setNeedsLayout()
            }
        }
    }

    public var spacing: CGFloat {
        didSet {
            if oldValue != spacing {
                setNeedsLayout()
            }
        }
    }

    public var columnWidth: CGFloat {
        (bounds.width - spacing * (CGFloat(columnCount) - 1.0)) / CGFloat(columnCount)
    }

    public var rowHeight: CGFloat {
        switch rowLayout {
        case .filled:
            let rowCount = self.rowCount
            return max(0.0, bounds.height - spacing * (CGFloat(rowCount) - 1.0)) / CGFloat(rowCount)
        case let .ratio(value):
            return columnWidth * value
        case let .fixed(value):
            return value
        case let .divide(value):
            return max(0.0, bounds.height - spacing * (CGFloat(value) - 1.0)) / CGFloat(value)
        }
    }

    public var rowCount: Int {
        let arrangedSubviewCount = arrangedSubviews.count
        return arrangedSubviewCount / columnCount + (arrangedSubviewCount % columnCount > 0 ? 1 : 0)
    }

    public init(frame: CGRect = CGRect.zero,
                columnCount: Int = 1,
                rowLayout: GridView.RowLayout = .filled,
                spacing: CGFloat = 0.0,
                arrangedSubviews: [UIView] = [])
    {
        self.columnCount = columnCount
        self.rowLayout = rowLayout
        self.spacing = spacing

        super.init(frame: frame, arrangedSubviews: arrangedSubviews)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        var result = size
        let rowCount = CGFloat(self.rowCount)
        let totalHeight = rowCount * rowHeight + (rowCount - 1) * spacing
        result.height = totalHeight
        return result
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let arrangedSubviewCount = arrangedSubviews.count
        if arrangedSubviewCount == 0 {
            return
        }

        let size = bounds.size
        if size.width <= 0 || size.height <= 0 {
            return
        }

        let columnCount = self.columnCount
        let columnWidth = self.columnWidth
        let rowCount = self.rowCount
        let rowHeight = self.rowHeight

        for row in 0 ..< rowCount {
            for column in 0 ..< columnCount {
                let index = row * columnCount + column
                if index < arrangedSubviewCount {
                    let subview = arrangedSubviews[index]
                    let subviewFrame = CGRect(x: columnWidth * CGFloat(column) + spacing * CGFloat(column), y: rowHeight * CGFloat(row) + spacing * CGFloat(row), width: columnWidth, height: rowHeight)

                    subview.frame = subviewFrame
                    subview.setNeedsLayout()
                }
            }
        }
    }
}
