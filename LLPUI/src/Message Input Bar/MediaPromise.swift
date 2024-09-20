//
//  PendingMedia.swift
//  LLPUI
//
//  Created by xueqooy on 2023/10/13.
//

import Foundation
import LLPUtils

public class MediaPromise: StateObservableObject, MediaConvertible {
    
    public enum State: Equatable {
        case pending
        case fulfilled
        case rejected
    }
    
    @EquatableState
    public private(set) var state: State = .pending
    
    public private(set) var value: MediaConvertible
        
    public init(placeholderMedia: MediaConvertible) {
        if placeholderMedia is MediaPromise {
            fatalError("Can't initialize with a promise")
        }
        
        value = placeholderMedia
    }
    
    public func resolve(_ media: MediaConvertible?) {
        guard state == .pending else {
            return
        }
        
        guard !(media is MediaPromise) else {
            fatalError("Can't resolve promise with a promise")
        }
        
        if let media = media {
            self.value = media
            state = .fulfilled
        } else {
            state = .rejected
        }
    }
    
    public func asMedia() -> Media {
        value.asMedia()
    }
    
    
}
