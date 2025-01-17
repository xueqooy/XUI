//
//  PlaybackProgressView.swift
//  XUI
//
//  Created by xueqooy on 2024/5/17.
//

import UIKit

public class PlaybackProgressView: UIView {
    public enum State: Equatable {
        case normal
        case failed
        case loading
    }

    public enum Event {
        case pendingTimeToSeekUpdated(TimeInterval)
        case requestToSeek(TimeInterval)
    }

    public struct TimeInfo: Equatable {
        public var duration: TimeInterval
        public var currentTime: TimeInterval
        public var bufferedPosition: TimeInterval

        public init(duration: TimeInterval = 0, currentTime: TimeInterval = 0, bufferedPosition: TimeInterval = 0) {
            self.duration = duration
            self.currentTime = currentTime
            self.bufferedPosition = bufferedPosition
        }
    }

    public var timeInfo: TimeInfo = .init() {
        didSet {
            guard oldValue != timeInfo else { return }

            update()
        }
    }

    public var state: State = .normal {
        didSet {
            guard oldValue != state else { return }

            update()
        }
    }

    public var eventHandler: ((Event) -> Void)?

    /// If not empty, it means currently seeking (dragging slider)
    private var seekingValue: Float?

    private let progressSlider = PlaybackProgressSlider()

    private lazy var timeLabel = UILabel(textColor: tintColor, font: UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .medium))
        .settingContentCompressionResistanceAndHuggingPriority(.required)

    private lazy var activityIndicator = ActivityIndicatorView(color: tintColor).then {
        $0.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }

    public init(tintColor: UIColor = .black) {
        super.init(frame: .zero)
        self.tintColor = tintColor

        let stackView = HStackView(alignment: .center, spacing: .XUI.spacing2) {
            timeLabel

            activityIndicator

            progressSlider
        }

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        progressSlider.eventHandler = { [weak self] event in
            guard let self else { return }

            switch event {
            case let .seekingUpdated(value):
                self.seekingUpdated(value)

            case .seekingEnded:
                self.seekingEnded()
            }
        }

        update()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func tintColorDidChange() {
        super.tintColorDidChange()

        activityIndicator.color = tintColor
        timeLabel.textColor = tintColor
    }

    public func sendActionsToSlider(for controlEvents: UIControl.Event, with value: Float? = nil) {
        if let value {
            progressSlider.value = value
        }
        progressSlider.sendActions(for: controlEvents)
    }

    private func update() {
        let currentTime = timeInfo.currentTime

        // Progress
        if seekingValue == nil {
            progressSlider.value = timeInfo.duration > 0 ? Float(currentTime / timeInfo.duration) : 0
            progressSlider.bufferedPosition = timeInfo.duration > 0 ? Float(timeInfo.bufferedPosition / timeInfo.duration) : 0
        }

        // Time
        switch state {
        case .normal:
            timeLabel.text = "\(currentTime.mediaTimeString) / \(timeInfo.duration.mediaTimeString)"

            setActivity(isActive: false)

        case .failed:
            timeLabel.text = "-:-- / -:--"

            setActivity(isActive: false)

        case .loading:
            timeLabel.text = "\(currentTime.mediaTimeString) / \(timeInfo.duration.mediaTimeString)"

            setActivity(isActive: true)
        }
    }

    private func setActivity(isActive: Bool) {
        activityIndicator.isHidden = !isActive
        if isActive {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func seekingUpdated(_ value: Float) {
        seekingValue = value

        eventHandler?(.pendingTimeToSeekUpdated(timeInfo.duration * Double(value)))
    }

    private func seekingEnded() {
        seekingValue = nil

        // Request to seek
        let seekTime = timeInfo.duration * Double(progressSlider.value)
        let updatedTimeInfo = TimeInfo(duration: timeInfo.duration, currentTime: seekTime, bufferedPosition: timeInfo.bufferedPosition)

        timeInfo = updatedTimeInfo

        eventHandler?(.requestToSeek(seekTime))
    }

    override public var intrinsicContentSize: CGSize {
        .init(width: UIView.noIntrinsicMetric, height: 30)
    }
}
