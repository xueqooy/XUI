//
//  TripleImageView.swift
//  XUI
//
//  Created by xueqooy on 2023/9/12.
//

import UIKit
import XKit

/// Display up to three images
public class TripleImageView: UIView {
    public enum Source: Equatable {
        case image(UIImage)
        case url(URL?, UIImage?)
    }

    public var sources: [Source] = [] {
        didSet {
            guard sources != oldValue else {
                return
            }

            update()
        }
    }

    public var tapHandler: ((TripleImageView, Int) -> Void)?

    private var shouldShowMoreLabel: Bool {
        sources.count > 3
    }

    private let hStackView: HStackView = {
        let stackView = HStackView(distribution: .fillEqually, spacing: 2)
        stackView.clipsToBounds = true
        return stackView
    }()

    private let vStackView: VStackView = {
        let stackView = VStackView(distribution: .fillEqually, spacing: 2)
        stackView.clipsToBounds = true
        return stackView
    }()

    private lazy var imageViews = [
        createImageView(),
        createImageView(),
        createImageView(),
    ]

    private let moreLabel = UILabel(textColor: .white, font: Fonts.h6, textAlignment: .center).then {
        $0.backgroundColor = .init(white: 0, alpha: .XUI.dimmingAlpha)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    public convenience init(sources: [Source] = [], tapHandler: ((TripleImageView, Int) -> Void)? = nil) {
        self.init(frame: .zero)

        defer {
            self.sources = sources
            self.tapHandler = tapHandler
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createImageView() -> UIImageView {
        AnimatedImageView(contentMode: .scaleAspectFill, clipsToBounds: true)
    }

    private func initialize() {
        layer.masksToBounds = true

        hStackView.addArrangedSubview(imageViews[0])
        hStackView.addArrangedSubview(vStackView)

        vStackView.addArrangedSubview(imageViews[1])
        vStackView.addArrangedSubview(imageViews[2])

        imageViews[2].addSubview(moreLabel)
        moreLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(hStackView)
        hStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        for imageView in imageViews {
            let tapGestureRecognizer = HighlightableTapGestureRecognizer(target: self, action: #selector(Self.tapGestureAction(_:)))
            imageView.addGestureRecognizer(tapGestureRecognizer)
            imageView.isUserInteractionEnabled = true
        }
    }

    private func update() {
        let count = sources.count
        switch count {
        case 0:
            hStackView.isHidden = true
        case 1:
            hStackView.isHidden = false
            vStackView.isHidden = true
        case 2:
            hStackView.isHidden = false
            vStackView.isHidden = false
            imageViews[1].isHidden = false
            imageViews[2].isHidden = true
        default:
            hStackView.isHidden = false
            vStackView.isHidden = false
            imageViews[1].isHidden = false
            imageViews[2].isHidden = false
            moreLabel.isHidden = !shouldShowMoreLabel
            moreLabel.text = "+\(count - 3)"
        }

        for (index, source) in sources.prefix(3).enumerated() {
            switch source {
            case let .image(image):
                imageViews[index].image = image
            case let .url(url, placeholder):
                imageViews[index].setImage(withURL: url, placeholder: placeholder)
            }
        }
    }

    @objc private func tapGestureAction(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let tapHandler = tapHandler else {
            return
        }

        let imageView = gestureRecognizer.view as! UIImageView
        let index = imageViews.firstIndex(of: imageView)!

        tapHandler(self, index)
    }
}
