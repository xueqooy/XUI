//
//  EmptyView.swift
//  XUI
//
//  Created by xueqooy on 2023/9/5.
//

import SnapKit
import UIKit
import XKit

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

    private lazy var textLabel = UILabel(textColor: Colors.bodyText1, font: Fonts.body1Bold, textAlignment: .center, numberOfLines: 0)
        .settingContentCompressionResistanceAndHuggingPriority(.required, for: .vertical)

    private lazy var detailTextLabel = UILabel(textColor: Colors.bodyText1, font: Fonts.body3, textAlignment: .center, numberOfLines: 0)
        .settingContentCompressionResistanceAndHuggingPriority(.defaultHigh)

    private lazy var actionButton = Button(designStyle: .primary) { [weak self] _ in
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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToWindow() {
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
            case let .fill(topPadding, bottomPadding):
                topSpacer.spacing = topPadding
                bottomSpacer.spacing = bottomPadding

                contentStackView.snp.remakeConstraints { make in
                    make.left.right.equalToSuperview().inset(CGFloat.XUI.spacing5)
                    make.top.bottom.equalToSuperview()
                }

            case let .centeredVertically(offset):
                topSpacer.spacing = 0
                bottomSpacer.spacing = 0

                contentStackView.snp.remakeConstraints { make in
                    make.left.right.equalToSuperview().inset(CGFloat.XUI.spacing5)
                    make.centerY.equalToSuperview().offset(offset)
                }

            case let .top(offset):
                topSpacer.spacing = 0
                bottomSpacer.spacing = 0

                contentStackView.snp.remakeConstraints { make in
                    make.left.right.equalToSuperview().inset(CGFloat.XUI.spacing5)
                    make.top.equalToSuperview().offset(offset)
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
                    .settingCustomSpacingAfter({
                        if showActionButton && !showText && !showDetailText {
                            return CGFloat.XUI.spacing6
                        }

                        return showText || showDetailText ? .XUI.spacing3 : 0
                    }())
            }

            if showText {
                textLabel
                    .settingCustomSpacingAfter({
                        if showActionButton && !showDetailText {
                            return CGFloat.XUI.spacing6
                        }

                        return showDetailText ? .XUI.spacing3 : 0
                    }())
            }

            if showDetailText {
                detailTextLabel
                    .settingCustomSpacingAfter(showActionButton ? .XUI.spacing6 : 0)
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
