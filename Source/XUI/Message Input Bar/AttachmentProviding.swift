//
//  AttachmentProviding.swift
//  XUI
//
//  Created by xueqooy on 2023/10/13.
//

import Combine
import Foundation
import UIKit

public protocol AttachmentProviding {
    var attachmentPublisher: AnyPublisher<MediaConvertible, Never> { get }

    func showPanel(in viewController: UIViewController, from anchorView: UIView, remainingNumberOfAttachmentsCanBeAdded: Int)
}
