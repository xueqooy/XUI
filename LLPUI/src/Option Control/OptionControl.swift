//
//  OptionControl.swift
//  AOMUtils
//
//  Created by xueqooy on 2023/3/8.
//

import UIKit
import SnapKit
import Combine

/// an optional control, with checkbox and radio style.
///
/// Once the radio is selected, it cannot be deselected by tapping.
///
public class OptionControl: UIControl {
    
    private struct Constants {
        static let componentSpacing: CGFloat = .LLPUI.spacing3
        static let indicatorSize = CGSize(width: 20, height: 20)
        static let disabledAlpha = 0.35
    }
    
    public enum Style {
        case checkbox, checkmark, radio, `switch`
    }
    
    /// Title or image placement
    public enum TitlePlacement {
        case leading, trailing
    }
    
    public enum Alignment {
        case automatic, top, center
        
        static func preferredAliginment(for style: Style) -> Alignment {
            if style == .switch {
                return .center
            } else {
                return .top
            }
        }
    }
    
    public let style: Style
    public let titlePlacement: TitlePlacement
    public let alignment: Alignment
    
    public var image: UIImage? {
        set {
            imageView.image = newValue
            
            maybeUpdateLayout()
        }
        get {
            imageView.image
        }
    }
    
    public var title: String? {
        set {
            titleLabel.text = newValue
            
            maybeUpdateLayout()
        }
        get {
            titleLabel.text
        }
    }
    
    public var richTitle: RichText? {
        set {
            titleLabel.richText = newValue
            
            maybeUpdateLayout()
        }
        get {
            titleLabel.richText
        }
    }
    
    public override var isSelected: Bool {
        didSet {
            if oldValue == isSelected {
                return
            }
            
            if style != .switch {
                indicatorView.isSelected = isSelected
            } else if switchView.isOn != isSelected {
                switchView.setOn(isSelected, animated: disablesAnimations ? false : window != nil)
            }
            
            if isStateChangeTriggerdByTap || !disablesActionSendForProgrammaticStateChange {
                sendActions(for: .valueChanged)
                seletionStateChangedAction?(self)
            }
        }
    }
        
    public override var isEnabled: Bool {
        didSet {
            if oldValue == isEnabled {
                return
            }
    
            horizontalStackView.alpha = isEnabled ? 1.0 : Constants.disabledAlpha
        }
    }
    
    public var disablesAnimations: Bool = false {
        didSet {
            if style != .switch {
                indicatorView.disablesAnimations = disablesAnimations
            }
        }
    }
    
    public var disablesActionSendForProgrammaticStateChange: Bool = false

    public var seletionStateChangedAction: ((OptionControl) -> Void)?
    
    private var isStateChangeTriggerdByTap: Bool = false
    
    private let horizontalStackView = HStackView()
    
    private lazy var imageView = UIImageView(tintColor: Colors.vibrantTeal)
        .settingContentCompressionResistanceAndHuggingPriority(.required, for: .horizontal)
    
    private(set) lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = Colors.title
        label.font = Fonts.body1
        label.numberOfLines = 0
//        // After testing, on iOS13, the label may be compressed horizontally, but not on iOS16. Add this line of code to fix the issue on iOS13 (it is uncertain which version will no longer need to do this)
//        label.settingContentCompressionResistanceAndHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    // The purpose of wrapping label: in lower versions (possibly lower than iOS14 or iOS15), UILabel (numberOfLines == 0) in UIStackView will cause StackView to be stretched unreasonably. Without limiting the width, the minimum width of StackView will be (text width * number of subviews),
    // Embedding the label in a UIView can fix this issue.
    private lazy var titleWrapperView = WrapperView(titleLabel)
    
    private lazy var flexibleSpacer: HSpacerView = HSpacerView(Constants.componentSpacing, compressionResistancePriority: .defaultHigh)
    
    private lazy var indicatorView = OptionControlIndicatorView(style: style)
    
    private lazy var switchView = Switch()
    
    private var hasDisplayedImage = false
    private var hasDisplayedTitle = false
    private var hasDisplayedIndicatorOrSwitch = false
    
    public init(style: Style, titlePlacement: TitlePlacement = .leading, alignment: Alignment = .automatic) {
        self.style = style
        self.titlePlacement = titlePlacement
        self.alignment = alignment
        
        super.init(frame: .zero)
                
        initialize()
    }
    
    public convenience init(style: Style, titlePlacement: TitlePlacement = .leading, alignment: Alignment = .automatic, title: String? = nil, image: UIImage? = nil) {
        self.init(style: style, titlePlacement: titlePlacement, alignment: alignment)
        
        self.title = title
        self.image = image
    }
    
    public convenience init(style: Style, titlePlacement: TitlePlacement = .leading, alignment: Alignment = .automatic, richTitle: RichText? = nil, image: UIImage? = nil) {
        self.init(style: style, titlePlacement: titlePlacement, alignment: alignment)
        
        self.richTitle = richTitle
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        
        if style == .switch {
            switchView.onTintColor = tintColor
        }
    }
    
    private func initialize() {
        tintColor = Colors.vibrantTeal
        
        addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        maybeUpdateLayout()

        let actualAlignment: Alignment
        if alignment == .automatic {
            actualAlignment = Alignment.preferredAliginment(for: style)
        } else {
            actualAlignment = alignment
        }
        
        if actualAlignment == .top {
            horizontalStackView.alignment = .top
        } else {
            horizontalStackView.alignment = .center
        }
        
        if style != .switch {
            indicatorView.snp.makeConstraints { make in
                make.size.equalTo(Constants.indicatorSize)
            }
            
            let tapGestureRegnizer = UITapGestureRecognizer(target: self, action: #selector(Self.tapped))
            addGestureRecognizer(tapGestureRegnizer)
        } else {
            switchView.addTarget(self, action: #selector(Self.tapped), for: .valueChanged)
        }
    }
    
    private func maybeUpdateLayout() {
        let shouldDisplayImage = image != nil
        let shouldDisplayTitle = !(title ?? "").isEmpty || !(richTitle?.attributedString.string ?? "").isEmpty
    
        guard shouldDisplayImage != hasDisplayedImage || shouldDisplayTitle != hasDisplayedTitle || !hasDisplayedIndicatorOrSwitch else {
            return
        }
            
        horizontalStackView.populate {
            switch titlePlacement {
            case .leading:
                if shouldDisplayImage {
                    imageView.settingCustomSpacingAfter(shouldDisplayTitle ? Constants.componentSpacing : 0)
                    
                    if !shouldDisplayTitle {
                        flexibleSpacer
                    }
                }
                
                if shouldDisplayTitle {
                    titleWrapperView
                    
                    flexibleSpacer
                }
                
                if style == .switch {
                    switchView
                } else {
                    indicatorView
                }
            case .trailing:
                if style == .switch {
                    switchView
                } else {
                    indicatorView
                }
                
                if shouldDisplayImage || shouldDisplayTitle {
                    flexibleSpacer
                }
                
                if shouldDisplayImage {
                    imageView.settingCustomSpacingAfter(shouldDisplayTitle ? Constants.componentSpacing : 0)
                }
                
                if shouldDisplayTitle {
                    titleWrapperView
                }
            }
        }
        
        hasDisplayedTitle = shouldDisplayTitle
        hasDisplayedImage = shouldDisplayImage
        hasDisplayedIndicatorOrSwitch = true
    }
    
    @objc private func tapped() {
        isStateChangeTriggerdByTap = true
        defer {
            isStateChangeTriggerdByTap = false
        }
        
        switch style {
        case .checkbox, .checkmark, .switch:
            isSelected.toggle()
        case .radio:
            if !isSelected {
                isSelected.toggle()
            }
        }
    }
}

