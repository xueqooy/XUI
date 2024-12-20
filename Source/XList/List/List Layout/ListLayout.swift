//
//  ListLayout.swift
//  XUI
//
//  Created by xueqooy on 2023/8/15.
//

import IGListKit
import UIKit

private let elementKindSectionBackground = "elementKindSectionBackground"
private let elementKindSectionInnerBackground = "elementKindSectionInnerBackground"
private let elementKindSectionConnection = "elementKindSectionConnection"

class ListLayout: ListCollectionViewLayout {
    var sectionBackgroundConfigurationProvider: ((Int) -> ListSectionBackgroundConfigurationProviding?)?
    var sectionInnerBackgroundConfigurationProvider: ((Int) -> ListSectionInnerBackgroundConfigurationProviding?)?
    var sectionConnectionConfigurationProvider: ((Int) -> ListSectionConnectionConfigurationProviding?)?

    private var sectionBackgroundDecorationViewLayoutAttributes = [Int: UICollectionViewLayoutAttributes]()
    private var sectionInnerBackgroundDecorationViewLayoutAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var sectionConnectionDecorationViewLayoutAttributes = [Int: UICollectionViewLayoutAttributes]()

    init(scrollDirection: UICollectionView.ScrollDirection) {
        super.init(stickyHeaders: false, scrollDirection: scrollDirection, topContentInset: 0, stretchToEdge: false)

        register(ListSectionBackgroundDecorationView.self,
                 forDecorationViewOfKind: elementKindSectionBackground)
        register(ListSectionBackgroundDecorationView.self,
                 forDecorationViewOfKind: elementKindSectionInnerBackground)
        register(ListSectionConnectionDecorationView.self, forDecorationViewOfKind: elementKindSectionConnection)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        sectionBackgroundDecorationViewLayoutAttributes.removeAll()
        sectionInnerBackgroundDecorationViewLayoutAttributes.removeAll()
        sectionConnectionDecorationViewLayoutAttributes.removeAll()

        guard let collectionView = collectionView, collectionView.numberOfSections > 0 else {
            return
        }

        func frame(for itemRange: Range<Int>? = nil, in section: Int) -> CGRect? {
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            let itemRange = itemRange ?? 0 ..< numberOfItems

            guard numberOfItems > 0,
                  let firstItem = layoutAttributesForItem(at: IndexPath(item: itemRange.startIndex, section: section)),
                  let lastItem = layoutAttributesForItem(at: IndexPath(item: max(itemRange.startIndex, itemRange.endIndex - 1), section: section))
            else {
                return nil
            }

            return firstItem.frame.union(lastItem.frame)
        }

        func resolvesectionBackgroundDecorationViewLayoutAttributes(for section: Int) {
            // Section background
            if let provider = sectionBackgroundConfigurationProvider?(section),
               let backgroundConfiguration = provider.sectionBackgroundConfiguration,
               let sectionFrame = frame(in: section)
            {
                let backgroundInset = provider.sectionBackgroundInset.edgeInsets(for: collectionView.effectiveUserInterfaceLayoutDirection)

                let layoutAttribute = ListSectionBackgroundDecorationViewLayoutAttributes(forDecorationViewOfKind: elementKindSectionBackground, with: IndexPath(item: 0, section: section))
                layoutAttribute.frame = sectionFrame.inset(by: backgroundInset)
                layoutAttribute.zIndex = -2
                layoutAttribute.configuration = backgroundConfiguration

                sectionBackgroundDecorationViewLayoutAttributes[section] = layoutAttribute
            }

            // Section inner background
            if let provider = sectionInnerBackgroundConfigurationProvider?(section),
               let itemRanges = provider.sectionInnerBackgroundItems?.findContinuousRanges()
            {
                for itemRange in itemRanges {
                    guard let backgroundConfiguration = provider.sectionInnerBackgroundConfiguration(for: itemRange), let frame = frame(for: itemRange, in: section) else {
                        continue
                    }

                    let backgroundInset = provider.sectionInnerBackgroundInset(for: itemRange).edgeInsets(for: collectionView.effectiveUserInterfaceLayoutDirection)

                    let firstIndexPath = IndexPath(item: itemRange.startIndex, section: section)

                    // A layoutAttributes corresponds to a view, so we only need to create one layoutAttributes within a range
                    let layoutAttribute = ListSectionBackgroundDecorationViewLayoutAttributes(forDecorationViewOfKind: elementKindSectionInnerBackground, with: firstIndexPath)
                    layoutAttribute.frame = frame.inset(by: backgroundInset)
                    layoutAttribute.zIndex = -1
                    layoutAttribute.configuration = backgroundConfiguration

                    for item in itemRange {
                        let indexPath = IndexPath(item: item, section: section)

                        sectionInnerBackgroundDecorationViewLayoutAttributes[indexPath] = layoutAttribute
                    }
                }
            }
        }

        // Connection point of current parent
        var currentParent: CGPoint?
        func resolvesectionConnectionDecorationViewLayoutAttributes(for section: Int) {
            guard let provider = sectionConnectionConfigurationProvider?(section), let connectionConfiguration = provider.sectionConnectionConfiguration else {
                return
            }

            switch connectionConfiguration.role {
            case .parent:
                if let sectionFrame = frame(in: section) {
                    currentParent = connectionConfiguration.anchor.point(for: sectionFrame)
                } else {
                    currentParent = nil
                }
            case .child:
                guard let parent = currentParent, let sectionFrame = frame(in: section) else {
                    return
                }
                let child = connectionConfiguration.anchor.point(for: sectionFrame)

                let direction: ListSectionConnectionDecorationViewLayoutAttributes.DrawingDirection

                if child.x == parent.x {
                    direction = .vertical
                } else if child.x > parent.x {
                    direction = .leftToRight
                } else {
                    direction = .rightToLeft
                }

                let minX = min(parent.x, child.x)
                let minY = min(parent.y, child.y)
                let maxX = max(parent.x, child.x)
                let maxY = max(parent.y, child.y)
                let frame = CGRect(x: minX, y: minY, width: max(2, maxX - minX), height: maxY - minY)

                let layoutAttribute = ListSectionConnectionDecorationViewLayoutAttributes(forDecorationViewOfKind: elementKindSectionConnection, with: IndexPath(item: 0, section: section))
                layoutAttribute.direction = direction
                layoutAttribute.frame = frame
                layoutAttribute.zIndex = -section - 3

                sectionConnectionDecorationViewLayoutAttributes[section] = layoutAttribute
            }
        }

        for section in 0 ..< collectionView.numberOfSections {
            resolvesectionBackgroundDecorationViewLayoutAttributes(for: section)
            resolvesectionConnectionDecorationViewLayoutAttributes(for: section)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElements(in: rect)

        layoutAttributes?.append(contentsOf: sectionBackgroundDecorationViewLayoutAttributes.values.filter {
            rect.intersects($0.frame)
        })

        layoutAttributes?.append(contentsOf: sectionInnerBackgroundDecorationViewLayoutAttributes.values.filter {
            rect.intersects($0.frame)
        })

        layoutAttributes?.append(contentsOf: sectionConnectionDecorationViewLayoutAttributes.values.filter {
            rect.intersects($0.frame)
        })

        return layoutAttributes
    }

    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let section = indexPath.section

        if elementKind == elementKindSectionBackground {
            return sectionBackgroundDecorationViewLayoutAttributes[section]

        } else if elementKind == elementKindSectionInnerBackground {
            return sectionInnerBackgroundDecorationViewLayoutAttributes[indexPath]

        } else if elementKind == elementKindSectionConnection {
            return sectionConnectionDecorationViewLayoutAttributes[section]
        }

        return super.layoutAttributesForDecorationView(ofKind: elementKind,
                                                       at: indexPath)
    }
}

extension Set where Element == Int {
    func findContinuousRanges() -> [Range<Int>] {
        guard !isEmpty else {
            return []
        }

        let sortedCollection = sorted()
        var result: [Range<Int>] = []
        var start = sortedCollection[0]
        var end = sortedCollection[0]

        for number in sortedCollection.dropFirst() {
            if number == end + 1 {
                end = number
            } else {
                result.append(start ..< (end + 1))
                start = number
                end = number
            }
        }

        result.append(start ..< (end + 1))
        return result
    }
}
