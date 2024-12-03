//
//  MessageInputBar.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/7.
//

import UIKit
import Combine
import LLPUtils

/**
 An auto growing text input bar
 
 The minimum configuration required to attach an input bar to the keyboard:
 ```
 class CustomViewController: UIViewController {

     override func loadView() {
         view = MessageInputBarHostingView(inputBar: messageInputBar)
     }
 }
 ```
 */

public class MessageInputBar: UIView {
    
    private static let contentInsets = UIEdgeInsets.init(uniformValue: .LLPUI.spacing3)

    public typealias Output = MessageInputBarOutput
    
    public typealias ToolActionHandler = (_ inputBar: MessageInputBar, _ sourceView: UIView, _ tool: Tool) -> Void
    public typealias SendActionHandler = (_ inputBar: MessageInputBar, _ sourceView: UIView, _ output: Output, _ completion: @escaping (Bool) -> Void) -> Void
    
    public enum Tool {
        case gif, attachment
    }
    
    public var sendButtonTitle: String = Strings.post {
        didSet {
            sendButton.configuration.title = sendButtonTitle
        }
    }
    
    public var isAttachmentButtonHidden: Bool = false {
        didSet {
            attachmentButton.isHidden = isAttachmentButtonHidden
        }
    }
    
    public var isGifButtonHidden: Bool = false {
        didSet {
            gifButton.isHidden = isGifButtonHidden
        }
    }
    
    public var isEnabled: Bool = true {
        didSet {
            guard oldValue != isEnabled else { return }
            
            update()
        }
    }
    
    public private(set) var isSending: Bool = false {
        didSet {
            guard oldValue != isSending else { return }
            
            update()
        }
    }
    
    public var toolAction: ToolActionHandler?
    
    public var sendAction: SendActionHandler?
    
    public let inputField = MessageInputField()

    public var validText: String? {
        let text = inputField.text?.trimmingWhitespacesAndAndNewlines() ?? ""
        
        if text.isEmpty {
            return nil
        } else {
            return text
        }
    }
    
    /// Text and contents to be sent
    public var pendingOutput: Output? {
        let text = validText
        let contents = plugins.reduce(into: [Any]()) { partialResult, plugin in
            partialResult.append(contentsOf: plugin.sendableContents)
        }
        
        if text == nil && contents.isEmpty {
            return nil
        } else {
            return Output(text: text, contents: contents)
        }
    }
    
    public var hasPendingOutput: Bool {
        validText != nil || hasSendableContentsInPlugins
    }
    
    public let topStackView = VStackView(spacing: .LLPUI.spacing2, layoutMargins:  .init(top: 0, left: 0, bottom: .LLPUI.spacing2, right: 0))
            
    private let backgroundView: BackgroundView = {
        var configuration = BackgroundConfiguration()
        configuration.fillColor = .white
        configuration.shadow.color = Colors.shadow
        configuration.shadow.blurRadius = .LLPUI.shadowBlurRadius
        configuration.shadow.offset = .LLPUI.shadowOffset
        
        return BackgroundView(configuration: configuration)
    }()
        
    private let contentView = UIView()

    private let horizontalStackView = HStackView(alignment: .center, spacing: .LLPUI.spacing3)
    
    private lazy var attachmentButton: Button = {
        let button = Button(designStyle: .borderless, image: Icons.attachment) { [weak self] in
            guard let self = self else { return }
            
            self.toolAction?(self, $0, .attachment)
        }
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    private lazy var gifButton: Button = {
        let button = Button(designStyle: .borderless, image: Icons.gif) { [weak self] in
            guard let self = self else { return }
            
            self.toolAction?(self, $0, .gif)
        }
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()

    private lazy var sendButton: Button = {
        var configuration = ButtonConfiguration()
        configuration.foregroundColor = Colors.teal
        configuration.title = sendButtonTitle
        configuration.titleFont = Fonts.body1Bold
        
        let button = Button(configuration: configuration) { [weak self] in
            guard let self = self, let sendAction = sendAction, let output = pendingOutput else { return }
            
            self.isSending = true
            
            sendAction(self, $0, output, { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    // Send successfully, invalidate all content
                    self.invalidate()
                }
                
                self.isSending = false
            })
        }
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
        
    private var textObservationCancellable: AnyCancellable?
    
    public convenience init(sendButtonTitle: String = Strings.post, sendAction: SendActionHandler? = nil, toolAction: ToolActionHandler? = nil) {
        self.init(frame: .zero)
        
        defer {
            self.sendButtonTitle = sendButtonTitle
            self.sendAction = sendAction
            self.toolAction = toolAction
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
        autoresizingMask = [.flexibleHeight]
        
        inputField.trailingViews = [attachmentButton, gifButton]
        
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide).inset(Self.contentInsets)
        }
        
        contentView.addSubview(topStackView)
        topStackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        contentView.addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints { make in
            make.top.equalTo(topStackView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        
        horizontalStackView.addArrangedSubview(inputField)
        horizontalStackView.addArrangedSubview(sendButton)
        
        textObservationCancellable = inputField.textPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.checkState()
            })
    }
    
    public override var intrinsicContentSize: CGSize {
        contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    public func invalidate() {
        inputField.text = nil
        invalidatePlugins()
    }
    
    public func checkState() {
        sendButton.isEnabled = hasPendingOutput && !hasPluginBlockSending
    }
    
    private func update() {
        let shouldDisableViews = !isEnabled || isSending
        
        if shouldDisableViews {
            disableUserInteractionOfPlugins()
            
            _ = inputField.resignFirstResponder()
            
            sendButton.isUserInteractionEnabled = false
            inputField.isEnabled = false
            gifButton.isEnabled = false
            attachmentButton.isEnabled = false
        } else {
            enableUserInteractionOfPlugins()
            
            sendButton.isUserInteractionEnabled = true
            inputField.isEnabled = true
            gifButton.isEnabled = true
            attachmentButton.isEnabled = true
            
        }
        
        if isSending {
            sendButton.isUserInteractionEnabled = false
            sendButton.update {
                $0.showsActivityIndicator = true
                $0.title = nil
            }
        } else {
            sendButton.update {
                $0.showsActivityIndicator = false
                $0.title = sendButtonTitle
            }
        }
    }
    
    // MARK: - Plugins

    private var hasSendableContentsInPlugins: Bool {
        for plugin in plugins {
            if !plugin.sendableContents.isEmpty {
                return true
            }
        }
        return false
    }
    
    private var hasPluginBlockSending: Bool {
        for plugin in plugins {
            if plugin.shouldBlockSending {
                return true
            }
        }
        return false
    }
    
    private var pluginObservationCancellables: [AnyCancellable]?
    
    public var plugins = [MessageInputPlugin]() {
        didSet {
            checkState()
            
            pluginObservationCancellables = plugins.map {
                $0.didAdd(to: self)
                
                return $0.stateDidChange
                    .sink { [weak self] _ in
                        guard let self = self else {
                            return
                        }
                        
                        self.checkState()
                    }
            }
        }
    }
    
    private func enableUserInteractionOfPlugins() {
        plugins.forEach { $0.isUserInteractionEnabled = true }
    }
    
    private func disableUserInteractionOfPlugins() {
        plugins.forEach { $0.isUserInteractionEnabled = false }
    }
    
    public func reloadPlugins() {
        plugins.forEach { $0.reloadData() }
    }
    
    public func invalidatePlugins() {
        plugins.forEach { $0.invalidate() }
    }

    @discardableResult public func input(_ input: Any) -> Bool {
        var result: Bool = false
        
        if let text = input as? String {
            inputField.text = text
            result = true
        }
        
        plugins.forEach {
            if $0.handleInput(input) {
                result = true
            }
        }
        
        return result
    }
}


extension MessageInputBar.Output: CustomStringConvertible {
    public var description: String {
        "{ text : \(text ?? "nil"), contents: \(contents) }"
    }
}
