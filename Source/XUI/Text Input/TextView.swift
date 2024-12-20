//
//  TextView.swift
//  XUI
//
//  Created by xueqooy on 2023/3/10.
//

import Combine
import SnapKit
import UIKit

/// Text view with placehoder
/// Removed the text margins that come with the system
open class TextView: UITextView {
    private enum Constants {
        static let textContainerInset = UIEdgeInsets(top: 10.3, left: 0, bottom: 8.3, right: 0)
    }

    public var placeholder: String? = nil {
        didSet {
            if oldValue == placeholder {
                return
            }

            placehoderLabel.text = placeholder
            updatePlacehoderHidden()
        }
    }

    public var placeholderColor: UIColor {
        set {
            placehoderLabel.textColor = newValue
        }
        get {
            placehoderLabel.textColor
        }
    }

    override open var font: UIFont? {
        didSet {
            placehoderLabel.font = font
        }
    }

    /// Whether to treat the content size  as the intrinsic content size
    public var automaticallyUpdatesIntrinsicContentSize: Bool = false {
        didSet {
            guard oldValue != automaticallyUpdatesIntrinsicContentSize else {
                return
            }

            invalidateIntrinsicContentSize()
        }
    }

    public var editingDidBeginPublisher: AnyPublisher<Void, Never> { editingDidBeginSubject.eraseToAnyPublisher() }
    public var editingChangedPublisher: AnyPublisher<Void, Never> { editingChangedSubject.eraseToAnyPublisher() }
    public var editingDidEndPublisher: AnyPublisher<Void, Never> { editingDidEndSubject.eraseToAnyPublisher() }

    private lazy var placehoderLabel: UILabel = {
        let label = UILabel()
        label.minimumScaleFactor = 0.75
        label.alpha = 0
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textStyleConfiguration = .placeholder
        return label
    }()

    private var notificationTokens = [NSObjectProtocol]()

    private var editingDidBeginSubject = PassthroughSubject<Void, Never>()
    private var editingChangedSubject = PassthroughSubject<Void, Never>()
    private var editingDidEndSubject = PassthroughSubject<Void, Never>()

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        scrollsToTop = false

        textStyleConfiguration = .textInput
        tintColor = Colors.teal
        backgroundColor = .clear

        // Removed the text margins
        textContainerInset = Constants.textContainerInset
        self.textContainer.lineFragmentPadding = 0

        setupPlacehoder()

        notificationTokens.append(contentsOf: [
            NotificationCenter.default.addObserver(forName: UITextView.textDidBeginEditingNotification, object: self, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.editingDidBeginSubject.send(())
            },
            NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updatePlacehoderHidden()
                self.editingChangedSubject.send(())
            },
            NotificationCenter.default.addObserver(forName: UITextView.textDidEndEditingNotification, object: self, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.editingDidEndSubject.send(())
            },
        ])
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        for token in notificationTokens {
            NotificationCenter.default.removeObserver(token)
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        guard automaticallyUpdatesIntrinsicContentSize else { return }

        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }

    override public var intrinsicContentSize: CGSize {
        if automaticallyUpdatesIntrinsicContentSize {
            let contentSize = contentSize
            let adjustedContentInset = adjustedContentInset

            return CGSize(width: contentSize.width + adjustedContentInset.horizontal, height: contentSize.height + adjustedContentInset.vertical)
        } else {
            return super.intrinsicContentSize
        }
    }

    private func updatePlacehoderHidden() {
        if text.isEmpty && !(placeholder ?? "").isEmpty {
            placehoderLabel.alpha = 1
        } else {
            placehoderLabel.alpha = 0
        }
    }

    private func setupPlacehoder() {
        addSubview(placehoderLabel)
        placehoderLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(Constants.textContainerInset.left)
            make.top.equalToSuperview().inset(Constants.textContainerInset.top)
            make.width.equalToSuperview().inset(Constants.textContainerInset.horizontal)
            make.height.lessThanOrEqualToSuperview().offset(-Constants.textContainerInset.vertical)
        }
    }

    // Manually trigger text change notification
    public func sendEditingChanged() {
        updatePlacehoderHidden()
        editingChangedSubject.send(())
    }
}
