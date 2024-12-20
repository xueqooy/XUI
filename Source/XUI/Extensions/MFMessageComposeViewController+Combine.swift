//
//  MFMessageComposeViewController+Combine.swift
//  XUI
//
//  Created by xueqooy on 2023/8/9.
//

import Combine
import MessageUI
import XKit

public extension MFMessageComposeViewController {
    /// Combine wrapper for `messageComposeViewController(_:didFinishWith:)`
    var didFinishPublisher: AnyPublisher<MessageComposeResult, Never> {
        delegateProxy.didFinishPublisher
    }

    private var delegateProxy: MFMessageComposeViewControllerDelegateProxy {
        MFMessageComposeViewControllerDelegateProxy.createDelegateProxy(for: self)
    }
}

private let delegateProxyAssociation = Association<MFMessageComposeViewControllerDelegateProxy>()

private class MFMessageComposeViewControllerDelegateProxy: NSObject, MFMessageComposeViewControllerDelegate {
    var didFinishPublisher: AnyPublisher<MessageComposeResult, Never> {
        didFinishSubject.eraseToAnyPublisher()
    }

    var didFinishSubject = PassthroughSubject<MessageComposeResult, Never>()

    static func createDelegateProxy(for object: MFMessageComposeViewController) -> MFMessageComposeViewControllerDelegateProxy {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let delegateProxy: MFMessageComposeViewControllerDelegateProxy

        if let associatedObject = delegateProxyAssociation[object] {
            delegateProxy = associatedObject
        } else {
            delegateProxy = MFMessageComposeViewControllerDelegateProxy()
            delegateProxyAssociation[object] = delegateProxy
        }

        delegateProxy.setDelegate(to: object)

        return delegateProxy
    }

    func messageComposeViewController(_: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        didFinishSubject.send(result)
    }

    func setDelegate(to object: MFMessageComposeViewController) {
        object.messageComposeDelegate = self
    }
}
