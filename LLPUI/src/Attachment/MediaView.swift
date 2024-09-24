//
//  MediaView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/9/14.
//

import UIKit
import LLPUtils

public class MediaView: UIView {

    public var media: Media? {
        didSet {
            guard oldValue != media else {
                return
            }
            
            updateContent()
        }
    }
    
    public var bottomView: UIView? {
        didSet {
            guard bottomView !== oldValue else { return }
            
            oldValue?.removeFromSuperview()
            
            if let bottomView {
                vStackView.addArrangedSubview(bottomView)
            }
        }
    }
    
    public var trailingView: UIView? {
        didSet {
            guard trailingView !== oldValue else { return }
            
            oldValue?.removeFromSuperview()
            
            if let trailingView {
                hStackView.addArrangedSubview(trailingView)
            }
        }
    }
    
    public var isLoading: Bool = false {
        didSet {
            guard oldValue != isLoading else {
                return
            }
            
            if isLoading {
                mediaLoadingView.startAnimating()
                mediaLoadingView.isHidden = false
            } else {
                mediaLoadingView.stopAnimating()
                mediaLoadingView.isHidden = true
            }
        }
    }
    
    public var isEnabled: Bool = true {
        didSet {
            guard isEnabled != oldValue else {
                return
            }
            
            tapGestureRecognizer.isEnabled = isEnabled

            vStackView.alpha = isEnabled ? 1 : .LLPUI.highlightAlpha
        }
    }
    
    public var tapAction: ((MediaView) -> Void)? {
        didSet {
            tapGestureRecognizer.isEnabled = tapAction != nil
        }
    }
    
    public var backgroundConfiguration = BackgroundConfiguration(fillColor: .white, strokeColor: Colors.line2, strokeWidth: 1, cornerStyle: .fixed(.LLPUI.smallCornerRadius)) {
        didSet {
            guard oldValue != backgroundConfiguration else { return }
            
            backgroundView.configuration = backgroundConfiguration
        }
    }
    
    public var contentInset: UIEdgeInsets {
        get {
            vStackView.layoutMargins
        }
        set {
            vStackView.layoutMargins = newValue
        }
    }
            
    private lazy var backgroundView = BackgroundView(configuration: backgroundConfiguration)
    
    private let vStackView = VStackView(spacing: .LLPUI.spacing2, layoutMargins: .init(top: .LLPUI.spacing3, left: .LLPUI.spacing3, bottom: .LLPUI.spacing3, right: .LLPUI.spacing3))
    
    private let hStackView = HStackView(alignment: .center, spacing: .LLPUI.spacing4, layoutMargins: .init(top: 0, left: 0, bottom: 0, right: .LLPUI.spacing1))

    private let labelStackView = VStackView()
    
    private lazy var mediaLoadingView = ActivityIndicatorView()
        .settingHidden(true)
    
    private let networkPictureLoadingView = ActivityIndicatorView()
    
    private let imageView = AnimatedImageView(contentMode: .scaleAspectFill, clipsToBounds: true, tintColor: Colors.teal)
        .settingSizeConstraint(CGSize.square(36))
    
    private let primaryLabel = UILabel(textColor: Colors.title, font: Fonts.body2Bold)
    
    private let secondaryLabel = UILabel(textColor: Colors.bodyText1, font: Fonts.body3)
    
    private let tapGestureRecognizer = HighlightableTapGestureRecognizer()
    
    public convenience init(media: Media? = nil, tapAction: ((MediaView) -> Void)? = nil) {
        self.init(frame: .zero)
        
        defer {
            self.media = media
            self.tapAction = tapAction
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {
        setContentHuggingPriority(.required, for: .vertical)
        
        labelStackView.populate {
            primaryLabel
            secondaryLabel
        }

        vStackView.populate {
            hStackView
        }
        
        hStackView.populate {
            imageView
            labelStackView
                .settingCustomSpacingAfter(0)
            HSpacerView.flexible()
            mediaLoadingView
        }
        
        imageView.addSubview(networkPictureLoadingView)
        networkPictureLoadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
            
        addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.isEnabled = false
        tapGestureRecognizer.addTarget(self, action: #selector(Self.tapGestureAction))
      
        vStackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func updateContent() {
        networkPictureLoadingView.stopAnimating()
        imageView.cancelCurrentImageLoad()
        
        hStackView.isHidden = false
        primaryLabel.numberOfLines = 2
        secondaryLabel.isHidden = false
        imageView.layer.cornerRadius = 0
        
        imageView.image = media?.image
        primaryLabel.text = media?.primaryText
        secondaryLabel.text = media?.secondaryText
        
        switch media {
        case .link(_, _, _):
            primaryLabel.numberOfLines = 1
            secondaryLabel.isHidden = false

        case .picture(_, _):
            imageView.layer.cornerRadius = 4
            
        case .networkPicture(_, let url, _):
            imageView.layer.cornerRadius = 4
            
            networkPictureLoadingView.startAnimating()
            networkPictureLoadingView.isHidden = false
            Task {
                _ = try? await imageView.setImage(withURL: url)
                networkPictureLoadingView.stopAnimating()
            }
            
        case .none:
            hStackView.isHidden = true
            
        default:
            break
        }
    }
    
    @objc private func tapGestureAction() {
        tapAction?(self)
    }
}

extension MediaView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let trailingView, trailingView.isUserInteractionEnabled {
            let touchPoint = touch.location(in: trailingView)
            
            if trailingView.bounds.contains(touchPoint) {
                return false
            }
        }
        
        if let bottomView, bottomView.isUserInteractionEnabled {
            let touchPoint = touch.location(in: bottomView)
            
            if bottomView.bounds.contains(touchPoint) {
                return false
            }
        }
        
        return true
    }
}
