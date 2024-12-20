//
//  AvatarView.swift
//  XUI
//
//  Created by xueqooy on 2023/9/12.
//

import SnapKit
import UIKit

public class AvatarView: UIView {
    private lazy var tapGestureRecognizer = HighlightableTapGestureRecognizer(target: self, action: #selector(Self.tapGestureAction))

    public var tapHandler: (() -> Void)? {
        didSet {
            if tapHandler == nil {
                removeGestureRecognizer(tapGestureRecognizer)
            } else {
                addGestureRecognizer(tapGestureRecognizer)
            }
        }
    }

    public var size: AvatarSize = .unspecified {
        didSet {
            guard size != oldValue else {
                return
            }

            invalidateIntrinsicContentSize()
        }
    }

    public var urlConfiguration: AvatarURLConfiguration? = nil {
        didSet {
            guard urlConfiguration != oldValue else {
                return
            }

            updateImageView()
        }
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    public convenience init(size: AvatarSize = .unspecified, urlConfiguration: AvatarURLConfiguration? = nil, tapHandler: (() -> Void)? = nil) {
        self.init(frame: .zero)

        defer {
            self.size = size
            self.urlConfiguration = urlConfiguration
            self.tapHandler = tapHandler
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    private func initialize() {
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)

        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)

        imageView.image = Icons.avatarPlaceholder

        addSubview(imageView)
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        imageView.layer.cornerRadius = bounds.height * 0.5
    }

    private func updateImageView() {
        imageView.cancelCurrentImageLoad()

        let urlConfiguration = self.urlConfiguration

        weak var weakSelf = self

        if let preferredURL = urlConfiguration?.preferredURL {
            Task {
                do {
                    try await imageView.setImage(withURL: preferredURL, placeholder: Icons.avatarPlaceholder)
                } catch {
                    guard !error.isImageCancelled else {
                        return
                    }

                    maybeUseAternativeURL()
                }
            }
        } else {
            maybeUseAternativeURL()
        }

        func maybeUseAternativeURL() {
            guard let self = weakSelf, self.urlConfiguration == urlConfiguration, let alternativeURL = urlConfiguration?.alternativeURL else {
                return
            }

            imageView.setImage(withURL: alternativeURL, placeholder: Icons.avatarPlaceholder)
        }
    }

    @objc private func tapGestureAction() {
        tapHandler?()
    }

    override public var intrinsicContentSize: CGSize {
        size.intrinsicContentSize
    }
}
