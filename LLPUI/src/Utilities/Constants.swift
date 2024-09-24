//
//  Constants.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/9/20.
//

import UIKit

public extension TimeInterval {
    enum LLPUI {
        public static let autoHideDelay: TimeInterval = -1
    }
    
    static func smartDelay(for text: String?) -> TimeInterval {
        let count = text?.count ?? 0
        if count <= 5 {
            return 1.5
        } else if count <= 10 {
            return 2
        } else if count <= 15 {
            return 2.5
        } else {
            return 3.0
        }
    }
}

public extension Int {
    enum LLPUI {
        public static let noSelection: Int = -1
    }
}

public extension CGFloat {
    enum LLPUI {
        public static let automaticDimension: CGFloat = -1
        
        /// 4
        public static let spacing1: CGFloat = 4
        /// 8
        public static let spacing2: CGFloat = 8
        /// 12
        public static let spacing3: CGFloat = 12
        /// 16
        public static let spacing4: CGFloat = 16
        /// 20
        public static let spacing5: CGFloat = 20
        /// 24
        public static let spacing6: CGFloat = 24
        /// 28
        public static let spacing7: CGFloat = 28
        /// 32
        public static let spacing8: CGFloat = 32
        /// 36
        public static let spacing9: CGFloat = 36
        /// 40
        public static let spacing10: CGFloat = 40
        
        /// 20
        public static let cornerRadius: CGFloat = 8
        /// 10
        public static let smallCornerRadius: CGFloat = 4
        /// 0.5
        public static let dimmingAlpha: CGFloat = 0.5
        /// 0.75
        public static let highlightAlpha: CGFloat = 0.8
        /// 10
        public static let shadowBlurRadius: CGFloat = 10
    }
}

public extension CGSize {
    enum LLPUI {
        public static let automaticDimension = CGSize(width: -1, height: -1)
        public static let shadowOffset = CGSize(width: 0, height: 5)
    }
}


public enum Insets {
    case directional(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat), nondirectional(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)
    
    public static let directionalZero: Insets = .directional(top: 0, leading: 0, bottom: 0, trailing: 0)
    public static let nondirectionalZero: Insets = .nondirectional(top: 0, left: 0, bottom: 0, right: 0)
    
    public static func directional(uniformValue value: CGFloat) -> Insets {
        .directional(top: value, leading: value, bottom: value, trailing: value)
    }
    
    public static func nondirectional(uniformValue value: CGFloat) -> Insets {
        .nondirectional(top: value, left: value, bottom: value, right: value)
    }
    
    public var top: CGFloat {
        switch self {
        case .directional(let top, _, _, _):
            return top
        case .nondirectional(let top, _, _, _):
            return top
        }
    }

    public var bottom: CGFloat {
        switch self {
        case .directional(_, _, let bottom, _):
            return bottom
        case .nondirectional(_, _, let bottom, _):
            return bottom
        }
    }
    
    public var horizontal: CGFloat {
        switch self {
        case .directional(_, let leading, _, let trailing):
            return leading + trailing
        case .nondirectional(_, let left, _, let right):
            return left + right
        }
    }
    
    public var vertical: CGFloat {
        switch self {
        case .directional(let top, _, let bottom, _):
            return top + bottom
        case .nondirectional(let top, _, let bottom, _):
            return top + bottom
        }
    }
    
    public func edgeInsets(for layoutDirection: UIUserInterfaceLayoutDirection) -> UIEdgeInsets {
        let isRTL = layoutDirection == .rightToLeft
        switch self {
        case .directional(let top, let leading, let bottom, let trailing):
            return UIEdgeInsets(top: top, left: isRTL ? trailing : leading, bottom: bottom, right: isRTL ? leading : trailing)
        case .nondirectional(let top, let left, let bottom, let right):
            return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
    }
    
    public func directionalEdgeInsets(for layoutDirection: UIUserInterfaceLayoutDirection) -> NSDirectionalEdgeInsets {
        let isRTL = layoutDirection == .rightToLeft
        switch self {
        case .directional(let top, let leading, let bottom, let trailing):
            return NSDirectionalEdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
        case .nondirectional(let top, let left, let bottom, let right):
            return NSDirectionalEdgeInsets(top: top, leading: isRTL ? right : left, bottom: bottom, trailing: isRTL ? left : right)
        }
    }
}

extension Insets: Equatable {}


public enum Direction {
    /// ⬇️
    case down
    /// ⬆️
    case up
    /// ➡️ (⬅️ for RTL)
    case fromLeading
    /// ⬅️ (➡️ for RTL)
    case fromTrailing
    
    var isVertical: Bool {
        switch self {
        case .down, .up:
            return true
        case .fromLeading, .fromTrailing:
            return false
        }
    }
    
    var isHorizontal: Bool { return !isVertical }

    var opposite: Direction {
        switch self {
        case .up:
            return .down
        case .down:
            return .up
        case .fromLeading:
            return .fromTrailing
        case .fromTrailing:
            return .fromLeading
        }
    }
}


public enum CornerStyle: Equatable {
    case fixed(CGFloat), capsule
}
