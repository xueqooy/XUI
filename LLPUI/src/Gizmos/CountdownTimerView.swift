//
//  CountdownTimerView.swift
//  LLPUI
//
//  Created by xueqooy on 2024/7/8.
//

import UIKit
import LLPUtils
import Combine

public class CountdownTimerView: UIView {
    
    public var totalSeconds: Int = 0 {
        didSet {
            totalSeconds = max(0, totalSeconds)
            remainingSeconds = min(totalSeconds, max(0, remainingSeconds))
            
            remainingSecondsSubject.send(remainingSeconds)
            
            update()
        }
    }
    
    public var remainingSeconds: Int = 0 {
        didSet {
            remainingSeconds = min(totalSeconds, max(0, remainingSeconds))
            
            remainingSecondsSubject.send(remainingSeconds)
            
            update()
        }
    }
    
    public var remainingSecondsPublisher: AnyPublisher<Int, Never> {
        remainingSecondsSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var title: String? {
        didSet {
            guard oldValue != title else { return }
            
            titleLabel.text = title
            
            if (title ?? "").isEmpty {
                titleLabel.isHidden = true
                hourglassImageView.settingCustomSpacingAfter(.LLPUI.spacing2)
                
            } else {
                titleLabel.isHidden = false
                hourglassImageView.settingCustomSpacingAfter(.LLPUI.spacing1)
            }
        }
    }
    
    private lazy var remainingSecondsSubject = CurrentValueSubject<Int, Never>(remainingSeconds)
    
    private let hourglassImageView = UIImageView(image: Icons.hourglass, tintColor: Colors.title)
        .settingContentCompressionResistanceAndHuggingPriority(.required)
    
    private lazy var titleLabel = UILabel(textColor: Colors.title, font: Fonts.caption, numberOfLines: 2)
        .settingContentCompressionResistanceAndHuggingPriority(.required)
    
    private let timeLabel: UILabel = {
        let label = InsetLabel(textColor: Colors.yellowOrange, font: UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .bold), textAlignment: .center)
        label.inset = .nondirectional(top: 0, left: 4, bottom: 0, right: 4)
        label.settingContentCompressionResistancePriority(.required + 1)
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = Colors.yellowOrange
        return progressView
    }()
    
    private lazy var progressStackView = VStackView(spacing: .LLPUI.spacing1) {
        timeLabel
        
        progressView
    }
    
    public private(set) var hasStarted: Bool = false
    
    private var timer: LLPUtils.Timer?
    
    public init(title: String? = nil, totalSeconds: Int) {
        super.init(frame: .zero)
        
        let showsTitle = !(title ?? "").isEmpty
        
        let stackView = HStackView(alignment: .center) {
            hourglassImageView
                .settingCustomSpacingAfter(.LLPUI.spacing2)

            titleLabel
                .settingHidden(true)
                .settingCustomSpacingAfter(.LLPUI.spacing2)
            
            progressStackView
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        defer {
            self.title = title
            self.totalSeconds = totalSeconds
            self.remainingSeconds = totalSeconds
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func start() {
        guard !hasStarted else {
            return
        }
        
        hasStarted = true
        
        timer = .init(interval: 1, isRepeated: true, work: { [weak self] in
            guard let self else { return }
            
            guard self.remainingSeconds > 0 else {
                self.stop()
                return
            }
            
            self.remainingSeconds -= 1
        })
        
        timer!.start()
    }
    
    public func stop() {
        hasStarted = false
        
        timer = nil
    }
    
    private func update() {
        if totalSeconds == 0 {
            progressStackView.isHidden = true
            
        } else {
            progressStackView.isHidden = false
            
            progressView.progress = totalSeconds > 0 ? Float(remainingSeconds) / Float(totalSeconds) : 0
            

            let hours = remainingSeconds / 3600
            let minutes = (remainingSeconds % 3600) / 60
            let seconds = remainingSeconds % 60
            
            if hours > 0 {
                timeLabel.text = String(format: "%02d : %02d : %02d", hours, minutes, seconds)
            } else {
                timeLabel.text = String(format: "%02d : %02d", minutes, seconds)
            }
        }
    }
}

