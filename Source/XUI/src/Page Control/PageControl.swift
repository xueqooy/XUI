//
//  PageControl.swift
//  XUI
//
//  Created by xueqooy on 2023/4/5.
//

import UIKit
import SnapKit
import XKit

public class PageControl: UIControl {

    enum IndicatorState {
        case hidden, small, normal, selected
    }
    
    private struct Constants {
        static let contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        static let maxVisiblePages = 7
        static let sideReservedPages = 2
        static let cancelContinuousTapInterval = 0.3
        static let animationDuration = 0.2
        static let panTriggerTranslation = 14.0
        static let panContinuousSelectionInterval = 0.1
        static let panCoutinuousSelectionDoubleRateTranslation = 50.0
    }

    private var modifyingNumberOfPages: Bool = false
    
    /// default is 0
    public var numberOfPages: Int = 0 {
        didSet {
            if oldValue == numberOfPages {
                return
            }
            
            if hidesForSinglePage {
                contentView.isHidden = numberOfPages <= 1
            } else {
                contentView.isHidden = false
            }
            
            modifyingNumberOfPages = true
            
            indicatorContentView.numberOfPages = numberOfPages
            currentPage = max(min(currentPage, numberOfPages - 1), 0)
            
            reset()
            updateIndicatorStates()
            
            modifyingNumberOfPages = false
        }
    }
    
    open var hidesForSinglePage: Bool = false {
        didSet {
            if hidesForSinglePage {
                contentView.isHidden = numberOfPages <= 1
            } else {
                contentView.isHidden = false
            }
        }
    }

    private var _currentPage: Int = 0 {
        didSet {
            if oldValue == _currentPage {
                return
            }
            
            preSelectedPage = oldValue
        
            if !modifyingNumberOfPages {
                updateIndicatorStates()
            }
            
            if shouldRespondToManualValueChange || changeTriggeredByGesture {
                sendActions(for: .valueChanged)
            }
        }
    }
    /// default is 0. Value is pinned to 0..numberOfPages-1
    public var currentPage: Int {
        set {
            _currentPage = max(min(newValue, numberOfPages - 1), 0)
        }
        get {
            _currentPage
        }
    }

    public var color: UIColor =  Colors.teal {
        didSet {
            if oldValue == color {
                return
            }
            
            indicatorContentView.color = color
            interactionBackgroundView.configuration.stroke.color = color
        }
    }

    /// If false, manually changing the `currentPage` will not trigger `.valueChanged`
    public var shouldRespondToManualValueChange: Bool = true
    
    private var changeTriggeredByGesture: Bool = false

    private lazy var contentView: UIView = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Self.contentTapGestureAction(_:)))

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.contentPanGestureAction(_:)))

        let view = UIView()
        view.layoutMargins = Constants.contentInset

        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(panGesture)
        return view
    }()

    private lazy var interactionBackgroundView: BackgroundView = {
        var config = BackgroundConfiguration()
        config.cornerStyle = .capsule
        config.stroke.width = 1
        config.stroke.color = color
        return BackgroundView(configuration: config)
    }()

    private lazy var indicatorContentView = PageControlIndicatorContentView(maxVisiblePages: Constants.maxVisiblePages, color: color)
    
    private var indicatorStates = [IndicatorState]()
    private var sideVisiblePages = (0, 0)
    private var preSelectedPage: Int = 0
    
    // Tap
    
    private lazy var cancelContinuousTapTimer = XKit.Timer(interval: Constants.cancelContinuousTapInterval, isRepeated: false) { [weak self] in
        self?.continuousTapAction = nil
    }
    private var continuousTapAction: (() -> Void)?

    // Pan
    
    private var lastPanLocation = CGPoint.zero
    private var panSelectionFeedback = HapticFeedback(type: .tap)
    private var continuousPanSelectionTimer: XKit.Timer?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }

    private func initialize() {
        interactionBackgroundView.alpha = 0.0

        addSubview(contentView)
        contentView.addSubview(interactionBackgroundView)
        contentView.addSubview(indicatorContentView)

        contentView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
        }

        interactionBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        indicatorContentView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.snp.margins)
        }
    }
    
    
    private func reset() {
        indicatorStates = Array(repeating: .normal, count: numberOfPages)
        sideVisiblePages = (0, Constants.maxVisiblePages - 1)
        preSelectedPage = 0
    }
    
    private func updateIndicatorStates() {
        let curSideVisiblePages = Self.sideVisiblePages(for: sideVisiblePages, totalPages: numberOfPages, maxVisiblePages: Constants.maxVisiblePages, sideReservedPages: Constants.sideReservedPages, preSelectedPage: preSelectedPage, selectedPage: currentPage)

        self.sideVisiblePages = curSideVisiblePages

        indicatorStates = indicatorStates.enumerated().map { (page, state) in
            Self.indicatorState(for: page, totalPages: numberOfPages, sideVisiblePages: sideVisiblePages, selectedPage: currentPage)
        }
        
        indicatorContentView.updateIndicatorStates(indicatorStates)
        
        invalidateIntrinsicContentSize()
    }

    @objc private func contentTapGestureAction(_ gesture: UITapGestureRecognizer) {
        guard let selectedIndicatorView = indicatorContentView.visibleIndicatorViews.first(where: {
            $0.state == .selected
        }) else {
            return
        }
        
        if continuousTapAction == nil {
            let point = gesture.location(in: selectedIndicatorView)
            if point.x < 0 {
                continuousTapAction = { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.changeTriggeredByGesture = true
                    self.currentPage -= 1
                    self.changeTriggeredByGesture = false
                }
            } else if point.x > selectedIndicatorView.bounds.width {
                continuousTapAction = { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.changeTriggeredByGesture = true
                    self.currentPage += 1
                    self.changeTriggeredByGesture = false
                }
            } else { // Tap on selected indicator, do nothing
                return
            }
        }
        
        continuousTapAction!()
        
        cancelContinuousTapTimer.start()
    }

    @objc private func contentPanGestureAction(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: indicatorContentView)
        
        switch gesture.state {
        case .began:
            lastPanLocation = location
            
            panSelectionFeedback.prepare()
            
            UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: [.curveEaseOut]) {
                self.interactionBackgroundView.alpha = 1.0
            }
            
        case .changed:
            let translation = location.x - lastPanLocation.x
            
            if location.x < 0 || location.x > indicatorContentView.bounds.maxX {
                let needDoubleRate = location.x < -Constants.panCoutinuousSelectionDoubleRateTranslation || (location.x - indicatorContentView.bounds.maxX) > Constants.panCoutinuousSelectionDoubleRateTranslation
                
                if let continuousPanSelectionTimer = continuousPanSelectionTimer {
                    let isDoubleRateTimer = continuousPanSelectionTimer.interval == Constants.panContinuousSelectionInterval * 0.5
                    if isDoubleRateTimer == needDoubleRate {
                        return
                    }
                }
                continuousPanSelectionTimer = Timer(interval: needDoubleRate ? Constants.panContinuousSelectionInterval * 0.5 : Constants.panContinuousSelectionInterval, isRepeated: true, work: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    let prePage = self.currentPage
                    if location.x < 0 {
                        self.changeTriggeredByGesture = true
                        self.currentPage -= 1
                        self.changeTriggeredByGesture = false
                    } else {
                        self.changeTriggeredByGesture = true
                        self.currentPage += 1
                        self.changeTriggeredByGesture = false
                    }
                    
                    if prePage != self.currentPage {
                        self.panSelectionFeedback.trigger()
                    }
                })
                continuousPanSelectionTimer?.start()
                continuousPanSelectionTimer?.fire()
            } else {
                continuousPanSelectionTimer = nil
                
                if translation >= Constants.panTriggerTranslation || translation <= -Constants.panTriggerTranslation  {
                   let prePage = currentPage
                   if translation > 0 {
                       self.changeTriggeredByGesture = true
                       currentPage += 1
                       self.changeTriggeredByGesture = false
                   } else {
                       self.changeTriggeredByGesture = true
                       currentPage -= 1
                       self.changeTriggeredByGesture = false
                   }
                   if prePage != currentPage {
                       lastPanLocation = location
                       panSelectionFeedback.trigger()
                   }
               }
            }

        case .ended, .cancelled:
            continuousPanSelectionTimer = nil

            UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: [.curveEaseOut]) {
                self.interactionBackgroundView.alpha = 0.0
            }
        default:
            break
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        var size = indicatorContentView.sizeThatFits(.zero)
        size.width += Constants.contentInset.horizontal
        size.height += Constants.contentInset.vertical
        return size
    }

}


private extension PageControl {
    static func indicatorState(for page: Int, totalPages: Int, sideVisiblePages: (Int, Int), selectedPage: Int) -> IndicatorState {
       if page == selectedPage {
            return .selected
        }
        
       let distance = abs(selectedPage - page)
       let sideVisiblePage = page < selectedPage ? sideVisiblePages.0 : sideVisiblePages.1
       let isInvisible = sideVisiblePage < distance
       
       if isInvisible {
           return .hidden
       }
       
       let isFirst = page == 0
       let isLast = page == totalPages - 1
       let isLastVisible = sideVisiblePage == distance
       
       if isLastVisible && !isFirst && !isLast {
           return .small
       }
       
       return .normal
    }

    static func sideVisiblePages(for preSideVisiblePages: (Int, Int), totalPages: Int, maxVisiblePages: Int, sideReservedPages: Int, preSelectedPage: Int, selectedPage: Int) -> (Int, Int) {
        let offset = selectedPage - preSelectedPage

        var leftVisiblePages: Int
        var rightVisiblePages: Int
        
        if offset == 0 {
            leftVisiblePages = max(min(maxVisiblePages - 1, preSideVisiblePages.0), 0)
            rightVisiblePages = max(maxVisiblePages - 1 - leftVisiblePages, 0)
        } else if offset < 0 {
            let leftPages = selectedPage
            if leftPages < preSideVisiblePages.0 {
                leftVisiblePages = leftPages
            } else if preSideVisiblePages.0 > sideReservedPages {
                leftVisiblePages = preSideVisiblePages.0 - 1
            } else {
                leftVisiblePages = preSideVisiblePages.0
            }
            
            leftVisiblePages = max(min(maxVisiblePages - 1, leftVisiblePages), 0)
            rightVisiblePages = max(maxVisiblePages - 1 - leftVisiblePages, 0)
        } else {
            let rightPages = totalPages - selectedPage - 1
            if rightPages < preSideVisiblePages.1 {
                rightVisiblePages = rightPages
            } else if preSideVisiblePages.1 > sideReservedPages {
                rightVisiblePages = preSideVisiblePages.1 - 1
            } else {
                rightVisiblePages = preSideVisiblePages.1
            }
            
            rightVisiblePages = max(min(maxVisiblePages - 1, rightVisiblePages), 0)
            leftVisiblePages = max(maxVisiblePages - 1 - rightVisiblePages, 0)
        }
        
        return (leftVisiblePages, rightVisiblePages)
    }
}
