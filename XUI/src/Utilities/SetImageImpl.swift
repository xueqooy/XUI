//
//  SetImageImpl.swift
//  XUI
//
//  Created by xueqooy on 2023/9/13.
//

import UIKit
import XKit

internal extension UIImageView {
    func setImage(withURL url: URL?, placeholder: UIImage? = nil, completion: ((UIImage?, Error?) -> Void)? = nil) {
//        sd_setImage(with: url, placeholderImage: placeholder) { image, error, _, _ in
//            completion?(image, error)
//        }
    }
    
    @discardableResult
    func setImage(withURL url: URL?, placeholder: UIImage? = nil) async throws -> UIImage? {
        try await withUnsafeThrowingContinuation { continuation in
            continuation.resume(returning: image)
//            sd_setImage(with: url, placeholderImage: placeholder) { image, error, _, _ in
//                if let error = error {
//                    continuation.resume(throwing: error)
//                } else {
//                    continuation.resume(returning: image)
//                }
//            }
        }
    }
    
    func cancelCurrentImageLoad() {
//        sd_cancelCurrentImageLoad()
    }
}

internal extension Error {
    var isImageCancelled: Bool {
//        (self as NSError).domain == SDWebImageErrorDomain && (self as NSError).code == SDWebImageError.cancelled.rawValue || isCancelled
        false
    }
}

//internal class AnimatedImageView: SDAnimatedImageView {}
internal class AnimatedImageView: UIImageView {}
