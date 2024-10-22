//
//  UIScrollView+Extensions.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/9/14.
//

import UIKit

public extension UIScrollView {
    
    // Describes the location of the scroll offset, relative to the content and scrollView
    enum ScrollLocationDescriptor {
        case excessivelyPrecedingContent // analogous to "Pull to Refresh"
        case inbounds // "normal scrolling", the user is moving through the content
        case excessivelyBeyondContent // the user has reached the bottom of the content and continues to scroll past, aka "past the last"
    }

    /// Whether the user is actively engaged with the scroll view
    /// Concatenation of various properties
    var userIsScrolling: Bool {
        return isTracking && isDragging
    }

    // Calculated Property reflecting the current ScrollLocationDescriptor based on various properties of the scrollView
    var scrollLocationDescriptor: ScrollLocationDescriptor {
        // The y-offset is adjusted to consider the top inset so the top scroll position is always 0 regardless of the content inset.
        let adjustedYOffset = contentOffset.y + contentInset.top
        let topInset = contentInset.top
        let bottomInset = contentInset.bottom //the footer's height is not reflected in contentSize, apparently?
        let contentHeight = contentSize.height + topInset + bottomInset //bottom inset can vary within the same list as the footer is dynamically loaded during scrolling (i.e. it will equal 1.0 until the footer is actually dequeued)
        let viewHeight = bounds.size.height

        //a negative y-offset is indicative of "pull to refresh"
        if adjustedYOffset < 0.0 {
            return .excessivelyPrecedingContent
        }

        //if the y offset combined with the height of the view is greater than the content, we're past the bottom of the scrollView's content
        if adjustedYOffset + viewHeight > contentHeight {
            return .excessivelyBeyondContent
        }

        //all other scenarios reflect the user scrolling between the top and bottom of the list
        return .inbounds
    }
    
    var canScroll: Bool {
        if bounds.width <= 0 || bounds.height <= 0 {
            return false
        }
        
        let canVerticalScroll = contentSize.height + adjustedContentInset.vertical > bounds.height
        let canHorizontalScroll = contentSize.width + adjustedContentInset.horizontal > bounds.width
        
        return canVerticalScroll || canHorizontalScroll
    }
    
    func scrollToBottom(forced: Bool = false, animated: Bool = true) {
        guard forced || canScroll else {
            return
        }

        if animated {
            setContentOffset(.init(x: contentOffset.x, y: contentSize.height + adjustedContentInset.bottom - bounds.height), animated: true)
        } else {
            contentOffset = .init(x: contentOffset.x, y: contentSize.height + adjustedContentInset.bottom - bounds.height)
        }
    }
    
    func scrollToTop(forced: Bool = false, animated: Bool = true) {
        guard forced || canScroll else {
            return
        }
        
        if animated {
            setContentOffset(.init(x: -adjustedContentInset.left, y: -adjustedContentInset.top), animated: true)
        } else {
            contentOffset = .init(x: -adjustedContentInset.left, y: -adjustedContentInset.top)
        }
    }
    
    func stopDeceleratingIfNeeded() {
        if isDecelerating {
            setContentOffset(contentOffset, animated: false)
        }
    }
    
    func configureWithFixedContentInset(_ contentInset: UIEdgeInsets, setToScrollIndicator: Bool = true) {
        contentInsetAdjustmentBehavior = .never
        automaticallyAdjustsScrollIndicatorInsets = false
        
        self.contentInset = contentInset
        scrollIndicatorInsets = contentInset
        
    }
}

