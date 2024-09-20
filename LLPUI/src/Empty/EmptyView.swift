//
//  EmptyView.swift
//  LLPUI
//
//  Created by xueqooy on 2023/9/5.
//

import UIKit
import SnapKit
import LLPUtils

public class EmptyView: UIView, Configurable {
    
    public var configuration: EmptyConfiguration {
        didSet {
            guard configuration != oldValue else { return }
            
            updateConfiguraiton()
        }
    }
        
    private lazy var topSpacer = VSpacerView(0)
    
    private lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var imageContainerView = AlignedContainerView(imageView, alignment: .centerHorizontally)
    
    private lazy var textLabel = UILabel(textColor: Colors.title, font: Fonts.title1, textAlignment: .center, numberOfLines: 0)
        .settingContentCompressionResistanceAndHuggingPriority(.required, for: .vertical)

    private lazy var detailTextLabel = UILabel(textColor: Colors.bodyText1, font: Fonts.body2, textAlignment: .center, numberOfLines: 0)
        .settingContentCompressionResistanceAndHuggingPriority(.defaultHigh)
    
    private lazy var actionButton = Button(designStyle: .primarySmall) { [weak self] _ in
        self?.configuration.action?.handler()
    }.settingContentCompressionResistanceAndHuggingPriority(.required)
    
    private lazy var actionContainerView = AlignedContainerView(actionButton, alignment: .centerHorizontally)
    
    private lazy var bottomSpacer = VSpacerView(0, huggingPriority: .defaultLow, compressionResistancePriority: .defaultLow)

    private lazy var loadingIndicator = ActivityIndicatorView()

    private let contentStackView = VStackView()
        
    private var validAlignment: EmptyConfiguration.Alignment?
    
    
    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        
        super.init(frame: .zero)
        
        initialize()
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        startLoadingIfNeeded()
    }
    
    public func startLoadingIfNeeded() {
        // Check visibility and restart loading if needed
        let isVisible = window != nil && !isHidden && alpha > 0.01
        
        if configuration.isLoading && isVisible {
            loadingIndicator.startAnimating()
            loadingIndicator.isHidden = false
        }
    }
    
    private func initialize() {
        addSubview(contentStackView)
        
        updateConfiguraiton()
    }
    
    private func updateConfiguraiton() {
        // Update Alignment
        
        if validAlignment == nil || validAlignment != configuration.alignment {
            switch configuration.alignment {
            case .fill(let topPadding, let bottomPadding):
                topSpacer.spacing = topPadding
                bottomSpacer.spacing = bottomPadding
                
                contentStackView.snp.remakeConstraints { make in
                    make.left.right.equalToSuperview().inset(CGFloat.LLPUI.spacing5)
                    make.top.bottom.equalToSuperview()
                }
                
            case .centeredVertically(let offset):
                topSpacer.spacing = 0
                bottomSpacer.spacing = 0
                
                contentStackView.snp.remakeConstraints { make in
                    make.left.right.equalToSuperview().inset(CGFloat.LLPUI.spacing5)
                    make.centerY.equalToSuperview().offset(offset)
                }
            }
        }
        
        validAlignment = configuration.alignment
        
        
        // Update content
        
        let showImage = configuration.image != nil
        let showText = configuration.text?.isEmpty == false
        let showDetailText = configuration.detailText?.isEmpty == false
        let showActionButton = configuration.action != nil && !configuration.action!.title.isEmpty
        let showLoadingIndicator = configuration.isLoading
        
        if showImage {
            imageView.image = configuration.image
        }
        
        if showText {
            textLabel.text = configuration.text
        }
        
        if showDetailText {
            detailTextLabel.text = configuration.detailText
        }
        
        if showActionButton {
            actionButton.configuration.title = configuration.action?.title
        }
        
        contentStackView.populate {
            topSpacer
            
            if showImage {
                imageContainerView
                    .settingCustomSpacingAfter(showText || showDetailText || showActionButton ? .LLPUI.spacing8 : 0)
            }
            
            if showText {
                textLabel
                    .settingCustomSpacingAfter(showDetailText || showActionButton ? .LLPUI.spacing4 : 0)
            }
            
            if showDetailText {
                detailTextLabel
                    .settingCustomSpacingAfter(showActionButton ? .LLPUI.spacing8 : 0)
            }
            
            if showActionButton {
                actionContainerView
            }
    
            bottomSpacer
        }
        
        if showLoadingIndicator {
            if loadingIndicator.superview !== self {
                addSubview(loadingIndicator)
                loadingIndicator.snp.remakeConstraints { make in
                    make.center.equalToSuperview()
                }
            }
            
            contentStackView.isHidden = true
            
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            
        } else {
            contentStackView.isHidden = false
            
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
        }
    }
}
