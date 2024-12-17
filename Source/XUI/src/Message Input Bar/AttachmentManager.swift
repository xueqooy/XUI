//
//  AttachmentManager.swift
//  XUI
//
//  Created by xueqooy on 2023/10/8.
//

import UIKit
import XKit
import Combine

public class AttachmentManager: StateObservableObject {
    
    @State
    public private(set) var attachments = [MediaConvertible]() {
        didSet {
            checkState()
            
            updateAttachmentViewContent()
            updateAttachmentViewVisibility()
            
            if attachments.isEmpty {
                drawer?.dismiss(animated: true)
            }
        }
    }
    
    public let maximumNumberOfAttachments: Int
    
    public weak var presentingViewController: UIViewController?
    
    public var tapAction: ((AttachmentManager, MediaConvertible) -> Void)?
        
    @EquatableState
    public private(set) var shouldBlockSending: Bool = false
    
    public var isAnyMediaPending: Bool {
        for attachment in attachments {
            if let promise = attachment as? MediaPromise, promise.state == .pending {
                return true
            }
        }
        
        return false
    }
    
    public var isUserInteractionEnabled: Bool = true {
        didSet {
            attachmentView.isEnabled = isUserInteractionEnabled
            
            listView?.isUserInteractionEnabled = isUserInteractionEnabled
            listView?.alpha = isUserInteractionEnabled ? 1.0 : .XUI.highlightAlpha
        }
    }
    
    private weak var messageInputBar: MessageInputBar? {
        didSet {
            updateAttachmentViewVisibility()
        }
    }
    
    private lazy var attachmentView = MediaView()
        
    private weak var listView: MediaListView?
    private weak var drawer: DrawerController?
    
    private var promiseCancellables = [AnyCancellable]()
    
    public init(maximumNumberOfAttachments: Int = .max, presentingViewController: UIViewController? = nil, tapAction: ((AttachmentManager, MediaConvertible) -> Void)? = nil) {
        self.maximumNumberOfAttachments = maximumNumberOfAttachments
        self.presentingViewController = presentingViewController
        self.tapAction = tapAction
    }
    
    public func insertAttachment(_ attachment: MediaConvertible, at index: Int) -> Bool {
        guard attachments.count < maximumNumberOfAttachments else {
            return false
        }
        
        var insertedAttachment: MediaConvertible
        
        if let promise = attachment as? MediaPromise {
            switch promise.state {
            case .pending:
                insertedAttachment = promise
                
                // Observe promise
                promise.stateDidChange
                    .sink { [weak promise, weak self] _ in
                        guard let self = self, let promise = promise else { return }
                        
                        guard let index = self.attachments.firstIndex(where: { ($0 as AnyObject) === promise }) else {
                            return
                        }
                        
                        if promise.state == .rejected {
                            // Remove promise attachment if rejected
                            self.removeAttachment(at: index)
                            
                        } else {
                            // Update attachment view and check state if fulfilled
                            self.updateAttachmentViewContent()
                            self.checkState()
                        }
                        
                    }
                    .store(in: &promiseCancellables)
    
            case .fulfilled:
                // Insert resolved media, just as regular media
                insertedAttachment = promise.value
                
            case .rejected:
                // Dot not insert a rejected media
                return false
            }
        } else {
            insertedAttachment = attachment
        }

        
        listView?.insertItem(createListItem(for: insertedAttachment), at: index)
        attachments.insert(insertedAttachment, at: index)
                
        return true
    }
    
    public func removeAttachment(at index: Int) {
        listView?.removeItem(at: index)
        attachments.remove(at: index)
    }
    
    public func checkState() {
        // Block sending if any promise is pending
        self.shouldBlockSending = isAnyMediaPending
    }
    
    private func updateAttachmentViewContent() {
        switch attachments.count {
        case 0:
            attachmentView.media = nil
            attachmentView.trailingView = nil
            attachmentView.tapAction = nil
        case 1:
            let attachment = attachments.first!
            
            let removeButton = Button(designStyle: .borderless, image: Icons.xmarkSmall) { [weak self] _ in
                self?.removeAttachment(at: 0)
            }
            
            attachmentView.media = attachment.asMedia()
            attachmentView.isLoading = isAnyMediaPending
            attachmentView.trailingView = removeButton
            attachmentView.tapAction = { [weak self] _ in
                guard let self = self, let tapAction = self.tapAction else {
                    return
                }
                
                if let promise = attachment as? MediaPromise {
                    tapAction(self, promise.value)
                } else {
                    tapAction(self, attachment)
                }
            }
        default:
            let indicatorImageView = UIImageView(image: Icons.arrowRight)
            indicatorImageView.tintColor = Colors.teal
            
            attachmentView.media = .unknown(name: Strings.attachments(attachments.count))
            attachmentView.isLoading = isAnyMediaPending
            attachmentView.trailingView = indicatorImageView
            attachmentView.tapAction = { [weak self] _ in
                self?.showAttachmentList()
            }
        }
    }
    
    private func updateAttachmentViewVisibility() {
        guard let topStackView = messageInputBar?.topStackView else {
            return
        }
        
        let visible = !attachments.isEmpty
        
        if visible && !topStackView.arrangedSubviews.contains(attachmentView) {
            topStackView.insertArrangedSubview(attachmentView, at: topStackView.arrangedSubviews.count)
        } else if !visible && topStackView.arrangedSubviews.contains(attachmentView) {
            attachmentView.removeFromSuperview()
        }
    }
    
    private func showAttachmentList() {
        guard let presentingViewController = presentingViewController, let messageInputBar = messageInputBar else {
            return
        }
        
        let items = attachments.map { createListItem(for: $0) }
        
        let listView = MediaListView(title: Strings.attachment, items: items) { [weak self] listView, index in
            guard let self = self, let tapAction = self.tapAction else {
                return
            }
            
            tapAction(self, listView.items[index].media)
        }
        
        let drawer = DrawerController(sourceView: messageInputBar, sourceRect: messageInputBar.bounds, configuration: .init(presentationDirection: .up, resizingBehavior: .dismissOrExpand))
        drawer.contentView = listView
        
        if DrawerController.recommendedPresentationStyle(for: presentingViewController, presentationDirection: .up) == .popover {
            drawer.preferredContentSize = .init(width: presentingViewController.view.bounds.width / 2, height: 0)
        } else {
            _ = messageInputBar.inputField.resignFirstResponder()
        }
        
        presentingViewController.present(drawer, animated: true)
        
        self.listView = listView
        self.drawer = drawer
    }
    
    private func createListItem(for attachment: MediaConvertible) -> MediaListView.Item {
        let media: MediaConvertible
        let isLoading: Bool
        
        if let promise = attachment as? MediaPromise {
            media = promise.value
            isLoading = promise.state == .pending
        } else {
            media = attachment
            isLoading = false
        }
        
        let item = MediaListView.Item(media: media, trailingButtonConfiguration: .init(image: Icons.xmarkSmall, action: { [weak self] view, index in
            self?.removeAttachment(at: index)
        }), isLoading: isLoading)
        
        if let promise = attachment as? MediaPromise {
            // Update list item if promise fulfilled
            promise.stateDidChange
                .sink { [weak item, weak promise] _ in
                    guard let item = item, let promise = promise, promise.state == .fulfilled else {
                        return
                    }
                    
                    item.media = promise.value
                    item.isLoading = false
                }
                .store(in: &promiseCancellables)
        }
        
        return item
    }
}

extension AttachmentManager: MessageInputPlugin {
    public var sendableContents: [Any] {
        attachments.compactMap {
            if let promise = $0 as? MediaPromise {
                if promise.state == .fulfilled {
                    return promise.value
                } else {
                    // Pending or rejected attachment is not sendable
                    return nil
                }
            } else {
                return $0
            }
        }
    }
    
    public func didAdd(to inputBar: MessageInputBar) {
        self.messageInputBar = inputBar
    }
    
    public func reloadData() {
        listView?.reload()
        updateAttachmentViewContent()
        updateAttachmentViewVisibility()
    }
    
    public func invalidate() {
        attachments = []
    }
    
    @discardableResult public func handleInput(_ input: Any) -> Bool {
        guard let attachment = input as? MediaConvertible else {
            return false
        }
        
        return insertAttachment(attachment, at: attachments.count)
    }
}
