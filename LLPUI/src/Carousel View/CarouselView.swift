//
//  CarouselView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/22.
//

import UIKit
import LLPUtils
import Combine

private let autoscrollInterval: TimeInterval = 5

public class CarouselView<Content : BindingView>: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    public typealias ViewModel = Content.ViewModel
    
    public var contentInitializer: (() -> Content)?
    
    public var didSelectContentHandler: ((Int) -> Void)?
        
    public override var clipsToBounds: Bool {
        didSet {
            collectionView.clipsToBounds = clipsToBounds
        }
    }
    
    /// `.LLPUI.automaticDimension` allows for flexible
    public var contentSize: CGSize = .zero {
        didSet {
            guard oldValue != contentSize else {
                return
            }
            
            if contentSize.width == .LLPUI.automaticDimension || contentSize.height == .LLPUI.automaticDimension {
                collectionLayoutPropertyObserver.addToView(collectionView)
                collectionFrameObservationCancellable =
                collectionLayoutPropertyObserver.propertyDidChangePublisher
                    .sink(receiveValue: { [weak self] _ in
                        guard let self else { return }
                        
                        self.updateLayoutItemSize()
                    })
            } else {
                collectionFrameObservationCancellable = nil
            }
            
            updateLayoutItemSize()
        }
    }
    
    private lazy var collectionLayoutPropertyObserver = ViewLayoutPropertyObserver(properties: [.frame, .center])
    
    private lazy var collectionViewLayout: CarouselCollectionViewLayout = {
        let layout = CarouselCollectionViewLayout()
        layout.minimumAlpha = 0.5
        layout.interitemSpacing = .LLPUI.spacing3
        layout.itemSize = .zero
        return layout
    }()
    
    public var viewModels: [ViewModel] = [] {
        didSet {
            pageControl.numberOfPages = viewModels.count
            
            collectionView.reloadData()
        }
    }
        
    public var isAutoscrollEnabled: Bool = false {
        didSet {
            guard oldValue != isAutoscrollEnabled else {
                return
            }
            
            if isAutoscrollEnabled {
                autoscrollTimer = LLPUtils.Timer(interval: autoscrollInterval, isRepeated: true) { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.maybeScrollToNextItem()
                }
                autoscrollTimer?.start()
            } else {
                autoscrollTimer?.stop()
                autoscrollTimer = nil
            }
        }
    }
    
    public var pageControlColor: UIColor {
        get {
            pageControl.color
        }
        set {
            pageControl.color = newValue
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CarouselViewCell<Content>.self, forCellWithReuseIdentifier: "CarouselViewCell")
        return collectionView
    }()
    
    private lazy var pageControl: PageControl = {
        let pageControl = PageControl()
        pageControl.hidesForSinglePage = true
        pageControl.shouldRespondToManualValueChange = false
        pageControl.addTarget(self, action: #selector(Self.pageControlValueChanged), for: .valueChanged)
        return pageControl
    }()
    
    private var autoscrollTimer: LLPUtils.Timer?
    
    private var collectionFrameObservationCancellable: AnyCancellable?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = VStackView(alignment: .fill, spacing: .LLPUI.spacing1) {
            collectionView
            pageControl
        }
      
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        defer {
            isAutoscrollEnabled = true
            contentSize = .square(.LLPUI.automaticDimension)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLayoutItemSize() {
        var itemSize: CGSize = .zero
        if contentSize.width == .LLPUI.automaticDimension {
            itemSize.width = collectionView.frame.width
        } else {
            itemSize.width = max(0, contentSize.width)
        }
        if contentSize.height == .LLPUI.automaticDimension {
            itemSize.height = collectionView.frame.height
        } else {
            itemSize.height = max(0, contentSize.height)
        }
         
        guard itemSize != collectionViewLayout.itemSize else {
            return
        }
        
        collectionViewLayout.itemSize = itemSize
        collectionViewLayout.invalidateLayout()
    }
    
    private func maybeScrollToNextItem() {
        guard viewModels.count > 1, window != nil, !isHidden, alpha > 0.01 else {
            return
        }
        
        let curItem = pageControl.currentPage
        let nextItem: Int
        
        if curItem == viewModels.count - 1 {
            nextItem = 0
        } else {
            nextItem = curItem + 1
        }
        
        pageControl.currentPage = nextItem
        scrollToItem(nextItem)
    }
    
    private func scrollToItem(_ item: Int) {
        collectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: [.centeredHorizontally], animated: true)
    }
    
    @objc private func pageControlValueChanged() {
        scrollToItem(pageControl.currentPage)
        
        if let autoscrollTimer = autoscrollTimer {
            autoscrollTimer.stop()
            autoscrollTimer.start()
        }
    }
    
    private func updatePageControl() {
        guard let page = collectionViewLayout.getAttributeForCenter(in: collectionView.bounds)?.index.item else { return }
        pageControl.currentPage = page
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = viewModels[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselViewCell", for: indexPath) as! CarouselViewCell<Content>
        if cell.content == nil {
            cell.content = contentInitializer?() ?? Content()
        }
        cell.content!.bindViewModel(viewModel)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        didSelectContentHandler?(indexPath.item)
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let autoscrollTimer = autoscrollTimer {
            autoscrollTimer.stop()
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let autoscrollTimer = autoscrollTimer {
            autoscrollTimer.start()
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updatePageControl()
        }
    }
    
    // FocusChangeDelegate will generate two inconsistent callbacks after calling scrollToItem(at:at:animated:true), which will cause pageControl animation exceptions, so UIScrollViewDelegate is used
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControl()
    }
}
