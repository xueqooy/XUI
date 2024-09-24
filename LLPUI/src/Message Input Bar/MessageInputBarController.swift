//
//  MessageInputBarController.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/13.
//

import Foundation
import Combine

public class MessageInputBarController {
    
    public typealias Output = MessageInputBarOutput
    
    public struct Configuration {
        public let placeholder: String
        public let sendButtonTitle: String
        public let maximumNumberOfAttachments: Int
        public let messageSender: MessageSending
        public let gifProvider: AttachmentProviding?
        public let attachmentProvier: AttachmentProviding?
        public let mediaViewer: MediaViewing?
        
        public init(placeholder: String = "", sendButtonTitle: String, maximumNumberOfAttachments: Int, messageSender: MessageSending, gifProvider: AttachmentProviding?, attachmentProvier: AttachmentProviding?, mediaViewer: MediaViewing?) {
            self.placeholder = placeholder
            self.sendButtonTitle = sendButtonTitle
            self.maximumNumberOfAttachments = maximumNumberOfAttachments
            self.messageSender = messageSender
            self.gifProvider = gifProvider
            self.attachmentProvier = attachmentProvier
            self.mediaViewer = mediaViewer
        }
    }
    
    public private(set) lazy var messageInputBar: MessageInputBar = {
        let bar = MessageInputBar(sendButtonTitle: configuration.sendButtonTitle)
        bar.sendButtonTitle = configuration.sendButtonTitle
        bar.inputField.placeholder = configuration.placeholder
        bar.isGifButtonHidden = configuration.gifProvider == nil
        bar.isAttachmentButtonHidden = configuration.attachmentProvier == nil
        bar.plugins = [attachmentManager]

        bar.toolAction = { [weak self] _, sourceView, tool in
            guard let self = self, let presentingViewController = self.presentingViewController else {
                return
            }
            
            guard checkAttachmentQuantityLimit() else {
                return
            }
   
            // Hide keyboard first
            _ = self.messageInputBar.inputField.resignFirstResponder()
            
            let remainingNumberOfAttachmentsCanBeAdded = attachmentManager.maximumNumberOfAttachments - attachmentManager.attachments.count
            
            switch tool {
            case .gif:
                self.configuration.gifProvider?.showPanel(in: presentingViewController, from: sourceView, remainingNumberOfAttachmentsCanBeAdded: remainingNumberOfAttachmentsCanBeAdded)
            case .attachment:
                self.configuration.attachmentProvier?.showPanel(in: presentingViewController, from: sourceView, remainingNumberOfAttachmentsCanBeAdded: remainingNumberOfAttachmentsCanBeAdded)
            }
        }
        
        bar.sendAction = { [weak self] _, _, ouput, completion in
            guard let self = self else {
                return
            }
            
            Task {
                let succeeded = await self.configuration.messageSender.sendMessage(ouput)
                
                await MainActor.run {
                    completion(succeeded)
                }
            }
        }
        return bar
    }()
    
    public let configuration: MessageInputBarController.Configuration
    public weak var presentingViewController: UIViewController?
        
    /// Attachment manager, under normal circumstances, we do not need to interact with it unless manual management of attachments is required
    public private(set) lazy var attachmentManager: AttachmentManager = {
        let attachmentManager = AttachmentManager(maximumNumberOfAttachments: configuration.maximumNumberOfAttachments, presentingViewController: presentingViewController) { [weak self] in
            guard let mediaViewer = self?.configuration.mediaViewer else {
                return
            }
            
            mediaViewer.viewMedia($1)
        }
        return attachmentManager
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(configuration: MessageInputBarController.Configuration, presentingViewController: UIViewController) {
        self.configuration = configuration
        self.presentingViewController = presentingViewController
        
        initialize()
    }
    
    public func initialize() {
        
        if let attachmentProvier = configuration.attachmentProvier {
            attachmentProvier.attachmentPublisher
                .sink { [weak self] attachment in
                    guard let self = self else {
                        return
                    }
                    
                    _ = self.addAttachment(attachment)
                }
                .store(in: &cancellables)
        }
        
        if let gifProvider = configuration.gifProvider {
            gifProvider.attachmentPublisher
                .sink { [weak self] attachment in
                    guard let self = self else {
                        return
                    }
                    
                    _ = self.addAttachment(attachment)
                }
                .store(in: &cancellables)
        }
    }
    
    private func addAttachment(_ attachment: MediaConvertible) -> Bool {
        guard checkAttachmentQuantityLimit() else {
            return false
        }
        
        messageInputBar.input(attachment)
        
        return true
    }
    
    private func checkAttachmentQuantityLimit() -> Bool {
        guard self.attachmentManager.attachments.count < configuration.maximumNumberOfAttachments else {
            self.presentingViewController?.showToast(style: .note, Strings.attachmentQuantityLimitReminder)
            return false
        }
        
        return true
    }
}
