//
//  MessageInputBarDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/10/8.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Combine
import UIKit
import XKit
import XUI

class MessageInputBarDemoController: DemoController, Editable {
    private lazy var messageSender = DemoMessageSender { [weak self] output, success in
        if success {
            self?.appendOutput(output)
            self?.outputField.text?.append("\(output)\n\n")

            Queue.main.execute(.delay(0.1)) {
                self?.formView.scrollingContainer.scrollToBottom()
            }
        } else {
            self?.showToast(style: .error, "Message sending failed")
        }
    }

    private lazy var gifProvider = DemoGifProvider()

    private lazy var attachmentProvider = DemoAttachmentProvider()

    private lazy var mediaViewer = DemoMediaViewer(presentingViewController: self)

    private let maximumNumberOfAttachments: Int = 5

    private lazy var messageInputBarController: MessageInputBarController = {
        let configuration = MessageInputBarController.Configuration(placeholder: "Write a Comment...", sendButtonTitle: Strings.post, maximumNumberOfAttachments: maximumNumberOfAttachments, messageSender: messageSender, gifProvider: gifProvider, attachmentProvier: attachmentProvider, mediaViewer: mediaViewer)

        let controller = MessageInputBarController(configuration: configuration, presentingViewController: self)

        return controller
    }()

    private lazy var outputField = MultilineInputField(label: "Output", placeholder: "Outputs will display here")

    override func loadView() {
        view = MessageInputBarHostingView(inputBar: messageInputBarController.messageInputBar)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        formView.scrollingContainer.alwaysBounceVertical = true
        formView.scrollingContainer.keyboardDismissMode = .interactive

        outputField.allowedAdditionalHeight = 500
        outputField.isEditable = false

        addRow(createLabelAndSwitchRow(labelText: "Make sending successful", isOn: messageSender.makesSendSuccessful, switchAction: { [weak self] isOn in
            self?.messageSender.makesSendSuccessful = isOn
        }))

        addRow(createLabelAndSwitchRow(labelText: "Enabled", isOn: messageInputBarController.messageInputBar.isEnabled, switchAction: { [weak self] isOn in
            self?.messageInputBarController.messageInputBar.isEnabled = isOn
        }))

        let promiseDelayField = InputField(label: "Resolve Delay of Promise Media", placeholder: "Seconds (Default 3)")
        promiseDelayField.text = "\(attachmentProvider.resolveDelayOfPromiseMedia)"
        promiseDelayField.keyboardType = .numberPad
        promiseDelayField.textPublisher
            .sink { [weak self] text in
                if let text = text, let seconds = Int(text), seconds >= 0 {
                    self?.attachmentProvider.resolveDelayOfPromiseMedia = seconds
                } else {
                    self?.attachmentProvider.resolveDelayOfPromiseMedia = 3
                }
            }
            .store(in: &cancellables)
        addRow(promiseDelayField, alignment: .fill)

        addRow(createButton(title: "Show Raw Output", action: { [weak self] button in
            guard let self = self else { return }

            let drawer = DrawerController(sourceView: button, sourceRect: button.bounds, configuration: .init(resizingBehavior: .dismiss))
            drawer.contentView = self.outputField
            // for popover in pad and landscape in phone
            drawer.preferredContentSize = .init(width: self.view.bounds.width / 2, height: 0)

            UIApplication.shared.keyWindows.first?.rootViewController?.present(drawer, animated: true)
        }))

//        Queue.main.execute(.delay(3)) {
//            let alert = UIAlertController(title: "Alert", message: "Test Alert", preferredStyle: .alert)
//            alert.addAction(.init(title: "ok", style: .default))
//            self.present(alert, animated: true)
//        }

        startEditing()
    }

    private func appendOutput(_ output: MessageInputBar.Output) {
        addSeparator()

        if let text = output.text {
            addRow(UILabel(text: text, textColor: Colors.bodyText1, font: Fonts.body1))
        }
        for content in output.contents {
            guard let media = content as? Media else {
                return
            }

            let view = MediaView(media: media, tapAction: { [weak self] _ in
                print("Tap Action -> \(media)")
                self?.mediaViewer.viewMedia(media)
            })
            addRow(view, alignment: .fill)
        }
    }

//    @objc override func hideKeyboard() {
//        super.hideKeyboard()
//
//        self.view.becomeFirstResponder()
//    }
}

// Attach Message Input Bar
// extension MessageInputBarDemoController: Editable {
//    override var inputAccessoryView: UIView? {
//        messageInputBarController.messageInputBar
//    }
//
//    override var canBecomeFirstResponder: Bool {
//        true
//    }
// }

class DemoMessageSender: MessageSending {
    var sendCompletion: ((MessageInputBarOutput, Bool) -> Void)?

    init(sendCompletion: ((MessageInputBarOutput, Bool) -> Void)? = nil) {
        self.sendCompletion = sendCompletion
    }

    var makesSendSuccessful: Bool = true

    func sendMessage(_ output: XUI.MessageInputBarOutput) async -> Bool {
        print("send \(output)")

        try? await Task.sleep(nanoseconds: 1_000_000_000)

        if makesSendSuccessful {
            await MainActor.run {
                self.sendCompletion?(output, true)
            }
            return true
        } else {
            await MainActor.run {
                self.sendCompletion?(output, false)
            }
            return false
        }
    }
}

class DemoGifProvider: AttachmentProviding {
    var attachmentPublisher: AnyPublisher<MediaConvertible, Never> {
        attachmentSubject.eraseToAnyPublisher()
    }

    private let attachmentSubject = PassthroughSubject<MediaConvertible, Never>()

    func showPanel(in _: UIViewController, from anchorView: UIView, remainingNumberOfAttachmentsCanBeAdded _: Int) {
        var configuration = Popover.Configuration()
        configuration.dismissMode = .tapOnOutsidePopover
        configuration.preferredDirection = .up

        let popover = Popover(configuration: configuration)

        let view = FormView()
        let attachButton = Button(designStyle: .primary, title: "Attach GIF") { [weak self, weak popover] _ in
            guard let self = self else { return }

            let gif: Media = .networkPicture(name: "GIF-\(Date().timeIntervalSince1970)", url: .randomImageURL(), placeholder: nil)

            self.attachmentSubject.send(gif)
            Task { @MainActor [popover] in
                popover?.hide()
            }
        }

        view.populate {
            FormRow(attachButton)
        }

        Task { @MainActor in
            popover.show(view, in: anchorView.window, from: anchorView)
        }
    }
}

class DemoAttachmentProvider: AttachmentProviding {
    var attachmentPublisher: AnyPublisher<MediaConvertible, Never> {
        attachmentSubject.eraseToAnyPublisher()
    }

    private let attachmentSubject = PassthroughSubject<MediaConvertible, Never>()

    var resolveDelayOfPromiseMedia: Int = 3

    func showPanel(in viewController: UIViewController, from anchorView: UIView, remainingNumberOfAttachmentsCanBeAdded _: Int) {
        var configuration = Popover.Configuration()
        configuration.dismissMode = .tapOnOutsidePopover
        configuration.preferredDirection = .up

        let popover = Popover(configuration: configuration)

        let view = FormView()
        view.itemSpacing = .XUI.spacing5
        let regularMediaButton = Button(designStyle: .primary, contentInsetsMode: .overrideHorizontal(20), title: "Attach Regular Attachment") { [weak self, weak popover] _ in
            guard let self = self else { return }

            self.attachmentSubject.send(MediaDemoController.randomMedia)
            Task { @MainActor [popover] in
                popover?.hide()
            }
        }

        let fulfillingPromiseMedia = Button(designStyle: .primary, contentInsetsMode: .overrideHorizontal(20), title: "Attach Fulfilling Promise Attachment") { [weak self, weak popover] _ in
            guard let self = self else { return }

            let placeholder: Media = .unknown(name: "Fulfilling Promise Attachment")
            let mediaPromise = MediaPromise(placeholderMedia: placeholder)

            Queue.main.execute(.delay(TimeInterval(self.resolveDelayOfPromiseMedia))) {
                let media: Media = .unknown(name: "Resolved Attachment")
                mediaPromise.resolve(media)
            }

            self.attachmentSubject.send(mediaPromise)
            Task { @MainActor [popover] in
                popover?.hide()
            }
        }

        let rejectingfPromiseMedia = Button(designStyle: .primary, contentInsetsMode: .overrideHorizontal(20), title: "Attach Rejecting Promise Attachment") { [weak self, weak popover] _ in
            guard let self = self else { return }

            let placeholder: Media = .unknown(name: "Rejecting Promise Attachment")
            let mediaPromise = MediaPromise(placeholderMedia: placeholder)

            Queue.main.execute(.delay(TimeInterval(self.resolveDelayOfPromiseMedia))) { [weak viewController] in
                viewController?.showToast(style: .error, "Attachment is Rejected")
                mediaPromise.resolve(nil)
            }

            self.attachmentSubject.send(mediaPromise)
            Task { @MainActor [popover] in
                popover?.hide()
            }
        }

        view.populate {
            FormRow(regularMediaButton)
            FormRow(fulfillingPromiseMedia)
            FormRow(rejectingfPromiseMedia)
        }

        Task { @MainActor in
            popover.show(view, in: anchorView.window, from: anchorView)
        }
    }
}

class DemoMediaViewer: MediaViewing {
    weak var presentingViewController: UIViewController?

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    func viewMedia(_ media: XUI.MediaConvertible) {
        if let messageInputBar = presentingViewController?.inputAccessoryView as? MessageInputBar {
            messageInputBar.resignFirstResponder()
        }

        let mediaView = MediaView(media: media.asMedia())

        let popupController = PopupController(configuration: .init())
        popupController.contentView = mediaView
        popupController.preferredContentSize = .init(width: 350, height: 0)

        (presentingViewController?.presentedViewController ?? presentingViewController)?.present(popupController, animated: true)
    }
}
