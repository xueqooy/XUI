//
//  FormRow.swift
//  XUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit
import XKit

/// `FormRow` serves as a container for single or multiple views. It is responsible for adding these views to the `FormView` and can be configured with alignment, height, and other properties.
public class FormRow: FormItem {
    public enum Constants {
        public static let defaultAlignment: Alignment = .fill
        public static let defaultSpacing: CGFloat = 0
        public static let defaultDistribution: Distribution = .fill
        public static let defaultVerticalAlignment: VerticalAlignment = .fill
    }

    public enum Alignment: Equatable {
        case fill, leading, center, trailing
    }

    public enum VerticalAlignment {
        case fill, top, center, bottom
    }

    public enum Distribution: Int {
        case fill, fillEqually, fillProportionally, equalSpacing, equalCentering
    }
    
    public enum HeightMode: Equatable {
        case automatic // based on intrinsic content height
        case fixed(CGFloat)
        case aspectRatio(CGFloat)
    }

    private enum Style {
        case singleView(UIView, insets: UIEdgeInsets?)
        case multipleViews([UIView], spacing: CGFloat, distribution: Distribution, verticalAlignment: VerticalAlignment, insets: UIEdgeInsets?)
    }

    private let style: Style
    
    @EquatableState
    public var heightMode: HeightMode {
        didSet {
            (loadedView as? FormRowView)?.height = height
        }
    }

    @EquatableState
    public var alignment: Alignment {
        didSet {
            (loadedView as? FormRowView)?.alignment = alignment
        }
    }

    public init(_ view: UIView, heightMode: HeightMode = .automatic, alignment: Alignment = Constants.defaultAlignment, insets: UIEdgeInsets? = nil) {
        style = .singleView(view, insets: insets)
        self.heightMode = heightMode
        self.alignment = alignment

        super.init()
    }
    
    public init(_ views: [UIView], spacing: CGFloat = Constants.defaultSpacing, heightMode: HeightMode = .automatic, distribution: Distribution = Constants.defaultDistribution, verticalAlignment: VerticalAlignment = Constants.defaultVerticalAlignment, alignment: Alignment = Constants.defaultAlignment, insets: UIEdgeInsets? = nil) {
        style = .multipleViews(views, spacing: spacing, distribution: distribution, verticalAlignment: verticalAlignment, insets: insets)
        self.heightMode = heightMode
        self.alignment = alignment

        super.init()
    }
    
    public convenience init(spacing: CGFloat = Constants.defaultSpacing, heightMode: HeightMode = .automatic, distribution: Distribution = Constants.defaultDistribution, verticalAlignment: VerticalAlignment = Constants.defaultVerticalAlignment, alignment: Alignment = Constants.defaultAlignment, insets: UIEdgeInsets = .zero, @ArrayBuilder<UIView> views: () -> [UIView]) {
        self.init(views(), spacing: spacing, heightMode: heightMode, distribution: distribution, verticalAlignment: verticalAlignment, alignment: alignment, insets: insets)
    }

    /// Get a certain view that force casting to the type
    /// - warning: Do not use it if you don't clear about the view type
    public func view<T: UIView>(of _: T.Type, at index: Int = 0) -> T {
        switch style {
        case let .singleView(view, _):
            return view as! T
        case let .multipleViews(views, _, _, _, _):
            return views[index] as! T
        }
    }

    override func createView() -> UIView {
        switch style {
        case let .singleView(view, insets):
            if let insets {
                return FormRowView(WrapperView(view, layoutMargins: insets), heightMode: heightMode, alignment: alignment)

            } else {
                return FormRowView(view, heightMode: heightMode, alignment: alignment)
            }

        case let .multipleViews(views, spacing, distribution, verticalAlignment, insets):
            let stackAlignemnt: UIStackView.Alignment = {
                switch verticalAlignment {
                case .fill:
                    return .fill
                case .top:
                    return .top
                case .center:
                    return .center
                case .bottom:
                    return .bottom
                }
            }()
            let stackDistribution = UIStackView.Distribution(rawValue: distribution.rawValue)!

            let hStack = HStackView(distribution: stackDistribution, alignment: stackAlignemnt, spacing: spacing, layoutMargins: insets, views: { return views })

            return FormRowView(hStack, height: height, alignment: alignment)
        }
    }
    
    // MARK: - Deprecated
    
    @available(*, deprecated, message: "Use heightMode instead")
    @EquatableState
    public var height: CGFloat? {
        didSet {
            (loadedView as? FormRowView)?.height = height
        }
    }
    
    @available(*, deprecated, message: "Use heightMode instead")
    public init(_ view: UIView, height: CGFloat?, alignment: Alignment = Constants.defaultAlignment, insets: UIEdgeInsets? = nil) {
        style = .singleView(view, insets: insets)
        self.heightMode = height != nil ? .fixed(height!) : .automatic
        self.alignment = alignment

        super.init()
    }
    
    @available(*, deprecated, message: "Use heightMode instead")
    public init(_ views: [UIView], spacing: CGFloat = Constants.defaultSpacing, height: CGFloat?, distribution: Distribution = Constants.defaultDistribution, verticalAlignment: VerticalAlignment = Constants.defaultVerticalAlignment, alignment: Alignment = Constants.defaultAlignment, insets: UIEdgeInsets? = nil) {
        style = .multipleViews(views, spacing: spacing, distribution: distribution, verticalAlignment: verticalAlignment, insets: insets)
        self.heightMode = height != nil ? .fixed(height!) : .automatic
        self.alignment = alignment

        super.init()
    }
    
    @available(*, deprecated, message: "Use heightMode instead")
    public convenience init(spacing: CGFloat = Constants.defaultSpacing, height: CGFloat?, distribution: Distribution = Constants.defaultDistribution, verticalAlignment: VerticalAlignment = Constants.defaultVerticalAlignment, alignment: Alignment = Constants.defaultAlignment, insets: UIEdgeInsets = .zero, @ArrayBuilder<UIView> views: () -> [UIView]) {
        self.init(views(), spacing: spacing, height: height, distribution: distribution, verticalAlignment: verticalAlignment, alignment: alignment, insets: insets)
    }
}

class FormRowView: UIView {
    weak var view: UIView?

    var heightMode: FormRow.HeightMode {
        didSet {
            if heightMode == oldValue {
                return
            }

            updateViewConstrants()
        }
    }
    
    var alignment: FormRow.Alignment {
        didSet {
            if alignment == oldValue {
                return
            }

            updateViewConstrants()
        }
    }
    
    init(_ view: UIView, heightMode: FormRow.HeightMode, alignment: FormRow.Alignment) {
        self.heightMode = heightMode
        self.alignment = alignment

        super.init(frame: .zero)

        self.view = view

        addSubview(view)
        updateViewConstrants()
    }

    private func updateViewConstrants() {
        guard let view = view else {
            return
        }
        view.snp.remakeConstraints { make in
            switch heightMode {
            case .automatic:
                break
            case .fixed(let height):
                make.height.equalTo(height)
            case .aspectRatio(let ratio):
                make.height.equalTo(view.snp.width).multipliedBy(ratio)
            }

            
            make.top.bottom.equalToSuperview()
            switch alignment {
            case .fill:
                make.leading.trailing.equalToSuperview()

            case .leading:
                make.width.lessThanOrEqualToSuperview()
                make.leading.equalToSuperview()

            case .center:
                make.width.lessThanOrEqualToSuperview()
                make.centerX.equalToSuperview()

            case .trailing:
                make.width.lessThanOrEqualToSuperview()
                make.trailing.equalToSuperview()
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Deprecated
    @available(*, deprecated, message: "Use heightMode instead")
    var height: CGFloat? {
        didSet {
            if height == oldValue {
                return
            }

            heightMode = height != nil ? .fixed(height!) : .automatic
        }
    }
    
    @available(*, deprecated, message: "Use heightMode instead")
    init(_ view: UIView, height: CGFloat?, alignment: FormRow.Alignment) {
        self.heightMode = height != nil ? .fixed(height!) : .automatic
        self.alignment = alignment

        super.init(frame: .zero)

        self.view = view

        addSubview(view)
        updateViewConstrants()
    }
}
