//
//  AttachmentProviding.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/13.
//

import Foundation
import Combine

public protocol AttachmentProviding {
    
    var attachmentPublisher: AnyPublisher<MediaConvertible, Never> { get }
    
    func showPanel(in viewController: UIViewController, from anchorView: UIView, remainingNumberOfAttachmentsCanBeAdded: Int)
}
