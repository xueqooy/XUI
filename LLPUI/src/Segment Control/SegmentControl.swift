//
//  SegmentControl.swift
//  LLPUI
//
//  Created by xueqooy on 2023/2/22.
//

import UIKit
import SnapKit
import LLPUtils
import Combine

open class SegmentControl: UIControl {
    
    public enum Style {
        case page, tab, toggle
    }
    
    /// If the `BadgeValue` is nil, do not display the Badge. If it is empty, display the Dot Badge. Otherwise, display the Text Badge
    public struct Item: Equatable {
        public let text: String
        public let badgeValue: String?
        
        
        public var displaysBadge: Bool {
            badgeValue != nil
        }
        
        public var displaysDotBadge: Bool {
            badgeValue != nil && badgeValue?.isEmpty == true
        }
        
        public init(text: String, badgeValue: String? = nil) {
            self.text = text
            self.badgeValue = badgeValue
        }
    }
    
    public let style: Style
    
    /// Items are all the same size if `true`
    public let fillEqually: Bool
    /// Effective width for calculating fixed width of item
    private var effectiveWidthForCalculating: CGFloat?
    /// Automatically calculate after size change when fill equally
    private var itemFixedWidth: CGFloat?
    
    public var items: [Item] {
        didSet {
            collectionView.reloadData()
            invalidateIntrinsicContentSize()
            
            let previousSelectedSegmentIndex = selectedSegmentIndex
            selectedSegmentIndex = previousSelectedSegmentIndex
            
            updateIndicatorPosition(fromIndex: .LLPUI.noSelection, toIndex: innerSelectedSegmentIndex, fraction: 1.0)
            
            collectionView.layoutIfNeeded()
        }
    }
    
    public var selectedSegmentIndex: Int  {
        get {
            innerSelectedSegmentIndex
        }
        set {
            if (0..<items.count).contains(newValue) {
                innerSelectedSegmentIndex = newValue
            } else {
                innerSelectedSegmentIndex = .LLPUI.noSelection
            }
        }
    }
    
    public var selectedSegmentIndexPublisher: AnyPublisher<Int, Never> {
        Publishers.ControlProperty(control: self, events: .valueChanged, keyPath: \.selectedSegmentIndex)
            .eraseToAnyPublisher()
    }
    
    public var selectionChanged: ((SegmentControl) -> Void)? = nil
    
    /// Whether to update the indicator position automatically,
    public var automaticallyUpdateIndicatorPostion: Bool = true
    
    
    open override var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            
            collectionView.alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    private var innerSelectedSegmentIndex: Int = .LLPUI.noSelection {
        didSet {
            guard oldValue != innerSelectedSegmentIndex else {
                return
            }
            
            sendActions(for: .valueChanged)
            selectionChanged?(self)
                        
            if automaticallyUpdateIndicatorPostion {
                let updateIndicatorPosition = {
                    self.updateIndicatorPosition(fromIndex: .LLPUI.noSelection, toIndex: self.innerSelectedSegmentIndex, fraction: 1)
                }
                if oldValue != .LLPUI.noSelection && innerSelectedSegmentIndex != .LLPUI.noSelection {
                    style.animateIndicator(indicatorView, updateIndicatorPosition: updateIndicatorPosition)
                } else {
                    updateIndicatorPosition()
                }
            }
            
            collectionView.scrollToItem(at: IndexPath(item: selectedSegmentIndex, section: 0), at: [], animated: true)
            
            var reloadIndexes = [IndexPath]()
            if (0..<items.count).contains(oldValue) {
                reloadIndexes.append(IndexPath(item: oldValue, section: 0))
            }
            if (0..<items.count).contains(innerSelectedSegmentIndex) {
                reloadIndexes.append(IndexPath(item: innerSelectedSegmentIndex, section: 0))
            }
            if !reloadIndexes.isEmpty {
                collectionView.reloadItems(at: reloadIndexes)
            }
        }
    }
    
    private(set) lazy var backgroundView =  BackgroundView()
    
    private(set) lazy var collectionView: SegmentControlCollectionView = {
        let collectionView = SegmentControlCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = style.contentInset
        return collectionView
    }()
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = style.itemSpacing
        return collectionViewLayout
    }()
    
    private lazy var indicatorView = SegmentControlIndicatorView(style: style)
        
    public init(style: SegmentControl.Style = .page, fillEqually: Bool = false, items: [Item] = []) {
        self.style = style
        self.fillEqually = fillEqually
        self.items = items
        
        super.init(frame: .zero)
                
        if let backgroundConfiguration = style.backgroundConfiguration {
            backgroundView.configuration = backgroundConfiguration
            addSubview(backgroundView)
            backgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
                
        collectionView.register(SegmentControlTextCell.self, forCellWithReuseIdentifier: NSStringFromClass(SegmentControlTextCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.addSubview(indicatorView)
        collectionView.indicatorView = indicatorView
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if fillEqually && bounds.width != effectiveWidthForCalculating {
            calculateItemFixedWidth()
            collectionView.reloadData()
            invalidateIntrinsicContentSize()
        }
        
        if automaticallyUpdateIndicatorPostion {
            updateIndicatorPosition(fromIndex: .LLPUI.noSelection, toIndex: innerSelectedSegmentIndex, fraction: 1.0)
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        let totalWidth = items.reduce(0) { partialResult, item in
            partialResult + self.size(for: item).width
        }
        + style.itemSpacing * max(CGFloat(items.count) - 1, 0.0) // item spacing
        + style.contentInset.left + style.contentInset.right // content inset
        return CGSize(width: totalWidth, height: style.intrinsicHeight)
    }
    
    public func updateIndicatorPosition(fromIndex: Int, toIndex: Int, fraction: CGFloat) {
        let fromAttributes = collectionView.layoutAttributesForItem(at: IndexPath(item: fromIndex, section: 0))
        let toAttributes = collectionView.layoutAttributesForItem(at: IndexPath(item: toIndex, section: 0))
                
        let fromRect = fromAttributes?.frame ?? .zero
        let toRect = toAttributes?.frame ?? .zero
        
        let x = fromRect.minX + (toRect.minX - fromRect.minX) * fraction
        let width = fromRect.width + (toRect.width - fromRect.width) * fraction
        
        indicatorView.frame = .init(x: x, y: toRect.minY, width: width, height: toRect.height)
        
        let position: SegmentControlIndicatorView.Position
        if toIndex == 0 {
            position = .left
        } else {
            position = toIndex == items.count - 1 ? .right : .center
        }
        indicatorView.position = position
    }
    
    private func calculateItemFixedWidth() {
        Asserts.failure("Call this method incorrectly when `fillEqually` is false", condition: fillEqually)
        if items.count == 0 {
            return
        }
        
        let totalWidth = bounds.width
        - style.itemSpacing * max(CGFloat(items.count) - 1, 0.0) // item spacing
        - (style.contentInset.left + style.contentInset.right) // content inset
        
        effectiveWidthForCalculating = totalWidth
        itemFixedWidth = max(totalWidth / CGFloat(items.count), 0.0)
    }
    
    private func size(for item: Item) -> CGSize {
        SegmentControlTextCell.size(forItem: item, style: style, itemFixedWidth: itemFixedWidth)
    }
    
}

extension SegmentControl: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        size(for: items[indexPath.item])
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(SegmentControlTextCell.self), for: indexPath) as! SegmentControlTextCell
        
        cell.setup(item: item, style: style, isSelected: indexPath.item == innerSelectedSegmentIndex)

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        innerSelectedSegmentIndex = indexPath.item
    }
}


extension SegmentControl.Item: ExpressibleByStringLiteral {
    
    public static func text(_ string: String) -> Self {
        Self(text: string)
    }
    
    public static func badgedText(_ string: String, value: String = "") -> Self {
        Self(text: string, badgeValue: value)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(text: value, badgeValue: nil)
    }
}

extension SegmentControl.Style {
    
    var backgroundConfiguration: BackgroundConfiguration? {
        switch self {
        case .page:
            return nil
        case .tab:
            return .overlay(color: Colors.darkTeal, cornerStyle: .capsule)
        case .toggle:
            var configuration = BackgroundConfiguration()
            configuration.fillColor = .white
            configuration.strokeColor = Colors.line2
            configuration.strokeWidth = 1
            configuration.cornerStyle = .fixed(8)
            return configuration
        }
    }
    
    var contentInset: UIEdgeInsets {
        switch self {
        case .page:
            return .init(top: 0, left: .LLPUI.spacing5, bottom: 0, right: .LLPUI.spacing5)
        case .tab:
            return .init(top: 6, left: 8, bottom: 6, right: 8)
        case .toggle:
            return .init(top: 0, left: 1, bottom: 0, right: 1)
        }
    }
    
    public var intrinsicHeight: CGFloat {
        switch self {
        case .page:
            return 48
        case .tab:
            return 56
        case .toggle:
            return 40
        }
    }
    
    var itemSpacing: CGFloat {
        switch self {
        case .page:
            return 0
        case .tab:
            return 6.0
        case .toggle:
            return 0
        }
    }
    
    func textFont(forSelected isSelected: Bool) -> UIFont {
        switch self {
        case .page:
            return isSelected ? Fonts.body3Bold : Fonts.body3
        case .tab:
            return Fonts.body4Bold
        case .toggle:
            return Fonts.body1
        }
    }
    
    func textColor(forSelected isSelected: Bool) -> UIColor {
        switch self {
        case .page:
            return Colors.bodyText1
        case .tab:
            return isSelected ? Colors.darkTeal : .white
        case .toggle:
            return isSelected ? .white : Colors.title
        }
    }
    
    var textInsets: UIEdgeInsets {
        switch self {
        case .page:
            return .init(top: 14, left: 16, bottom: 14, right: 16)
        case .tab:
            return .init(top: 12, left: 14, bottom: 12, right: 14)
        case .toggle:
            return .init(top: 9.5, left: 25, bottom: 9.5, right: 25)
        }
    }
            
    var sliderThickness: CGFloat {
        switch self {
        case .page:
            return 3
        case .tab:
            return 44
        case .toggle:
            return 38
        }
    }
    
    var sliderColor: UIColor {
        switch self {
        case .tab:
            return .white
        default:
            return Colors.mediumTeal
        }

    }
    
    var sliderCornerStyle: CornerStyle {
        switch self {
        case .page:
            return .fixed(0)
        case .tab:
            return .capsule
        case .toggle:
            return .fixed(7)
        }
    }
    
    func sliderMaskedCorner(for position: SegmentControlIndicatorView.Position) -> CACornerMask {
        switch self {
        case .page, .tab:
            return [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case .toggle:
            switch position {
            case .left:
                return [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            case .center:
                return []
            case .right:
                return [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
        }
    }
    
    func animateIndicator(_ indicatorView: SegmentControlIndicatorView, updateIndicatorPosition: @escaping () -> Void) {
        switch self {
        case .page, .tab:
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: updateIndicatorPosition)
        case .toggle:
            indicatorView.layer.animateScale(from: 1.1, to: 1, duration: 0.15, timingFunction: .spring)
            updateIndicatorPosition()
        }
    }
}
