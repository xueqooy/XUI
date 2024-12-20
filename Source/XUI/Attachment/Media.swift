//
//  Media.swift
//  XUI
//
//  Created by xueqooy on 2023/10/8.
//

import CoreServices
import UIKit

public enum Media: Equatable {
    public enum LinkType: Equatable, CaseIterable {
        case googleDoc
        case googleSheet
        case googleSlide
        case unknown
    }

    public enum DocumentType: Equatable, CaseIterable {
        case googleDoc
        case googleSheet
        case googleSlide
        case pdf
        case word
        case excel
        case ppt
        case zip
        case unknown(ext: String? = nil)

        public static var allCases: [Media.DocumentType] = [.googleDoc, .googleSheet, .googleSlide, .pdf, .word, .excel, .ppt, .zip]
    }

    case link(title: String, content: String, type: LinkType = .unknown)
    case document(name: String, type: DocumentType = .unknown())
    case video(name: String)
    case audio(name: String)
    case picture(name: String, image: UIImage)
    case networkPicture(name: String, url: URL, placeholder: UIImage? = nil)
    case unknown(name: String)
}

extension Media.LinkType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .googleDoc:
            return "Google Doc"
        case .googleSheet:
            return "Google Sheet"
        case .googleSlide:
            return "Google Slide"
        case .unknown:
            return "Unknown"
        }
    }

    public var image: UIImage {
        switch self {
        case .googleDoc:
            return Icons.mediaGoogleDoc
        case .googleSheet:
            return Icons.mediaGoogleSheet
        case .googleSlide:
            return Icons.mediaGoogleSlide
        case .unknown:
            return Icons.mediaLink
        }
    }
}

extension Media.DocumentType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .googleDoc:
            return "Google Doc"
        case .googleSheet:
            return "Google Sheet"
        case .googleSlide:
            return "Google Slide"
        case .pdf:
            return "PDF"
        case .word:
            return "Word"
        case .excel:
            return "Excel"
        case .ppt:
            return "PPT"
        case .zip:
            return "Zip"
        case let .unknown(ext):
            if let ext = ext {
                return ext
            } else {
                return "Unknown"
            }
        }
    }

    public var image: UIImage {
        switch self {
        case .googleDoc:
            return Icons.mediaGoogleDoc
        case .googleSheet:
            return Icons.mediaGoogleSheet
        case .googleSlide:
            return Icons.mediaGoogleSlide
        case .pdf:
            return Icons.mediaPDF
        case .word:
            return Icons.mediaWord
        case .excel:
            return Icons.mediaExcel
        case .ppt:
            return Icons.mediaPPT
        case .zip:
            return Icons.mediaZip
        case let .unknown(ext):
            if let ext = ext,
               let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)
            {
                let identifier = Unmanaged.fromOpaque(uti.toOpaque()).takeUnretainedValue() as CFString

                switch identifier as String {
                case "com.adobe.pdf":
                    return Icons.mediaPDF
                case "com.microsoft.excel.xls", "org.openxmlformats.spreadsheetml.sheet":
                    return Icons.mediaExcel
                case "com.microsoft.word.doc", "org.openxmlformats.wordprocessingml.document":
                    return Icons.mediaWord
                case "com.microsoft.powerpoint.​ppt", "org.openxmlformats.presentationml.presentation":
                    return Icons.mediaPPT
                case "org.gnu.gnu-zip-archive", "org.gnu.gnu-zip-tar-archive", "com.pkware.zip-archive", "public.zip-archive":
                    return Icons.mediaZip
                default:
                    break
                }
            }

            return Icons.mediaDocument
        }
    }
}

extension Media: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .link(title, content, type):
            return "link : { title: \(title), content: \(content), type: \(type) }"
        case let .document(name, type):
            return "document : { name: \(name), icon: \(type) }"
        case let .video(name):
            return "video : { name: \(name) }"
        case let .picture(name, image):
            return "picture : { name: \(name), image: \(image) }"
        case let .networkPicture(name, url, placeholder):
            return "networkPicture : { name: \(name), url: \(url), placeholder: \(String(describing: placeholder)) }"
        case let .unknown(name):
            return "unspecified : { name : \(name) }"
        case let .audio(name: name):
            return "audio : { name : \(name)}"
        }
    }

    public var image: UIImage? {
        switch self {
        case let .link(_, _, type):
            return type.image
        case let .document(_, type):
            return type.image
        case .video:
            return Icons.mediaVideo
        case .audio:
            return Icons.mediaAudio
        case let .picture(_, image):
            return image
        case let .networkPicture(_, _, placeholder):
            return placeholder
        case .unknown:
            return Icons.mediaUnknown
        }
    }

    public var imageURL: URL? {
        switch self {
        case let .networkPicture(_, url, _):
            return url
        default:
            return nil
        }
    }

    public var primaryText: String {
        switch self {
        case let .link(title, _, _):
            return title
        case let .document(name, _):
            return name
        case let .video(name):
            return name
        case let .audio(name):
            return name
        case let .picture(name, _):
            return name
        case let .networkPicture(name, _, _):
            return name
        case let .unknown(name):
            return name
        }
    }

    public var secondaryText: String? {
        switch self {
        case let .link(_, content, _):
            return content
        default:
            return nil
        }
    }
}

public protocol MediaConvertible {
    func asMedia() -> Media
}

extension Media: MediaConvertible {
    public func asMedia() -> Media {
        self
    }
}
