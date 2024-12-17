//
//  RichText.Attachment.swift
//  XUI
//
//  Created by xueqooy on 2023/8/18.
//

import UIKit

public protocol ViewAttachmentSizeProviding {
    func viewAttachmentSize(for lineFragment: CGRect) -> CGSize
}

public extension RichText {
    
    struct Attachment {
        
        enum Content {
            case image(UIImage) // Not support for UITextField
            case view(UIView) // Only support for UITextView
        }
        
        public enum SizeMode {
            /// Original size but width not exceeding line fragment width
            case automatic
            /// Specified size
            case specified(CGSize)
        }
        
        public enum Alignment {
            case center
            case offset(CGPoint)
        }
    
        public struct Layout {
            public let sizeMode: SizeMode
            public let alignment: Alignment
            
            public static func automatic(_ alignment: Alignment = .center) -> Self {
                .init(sizeMode: .automatic, alignment: alignment)
            }
            
            public static func specified(_ size: CGSize, _ alignment: Alignment = .center) -> Self {
                .init(sizeMode: .specified(size), alignment: alignment)
            }
        }
        
        let content: Content
        let layout: Layout
        
        let sizingFont: UIFont?
        
        public static func image(_ image: UIImage, _ layout: Layout = .automatic(), sizingFont: UIFont? = nil) -> Self {
            .init(content: .image(image), layout: layout, sizingFont: sizingFont)
        }
        
        public static func view(_ view: UIView, _ layout: Layout = .automatic(), sizingFont: UIFont? = nil) -> Self {
            .init(content: .view(view), layout: layout, sizingFont: sizingFont)
        }
                
        func asTextAttachment() -> NSTextAttachment {
            TextAttachment(content: content, layout: layout, sizingFont: sizingFont)
        }
    }
    
    
    internal class TextAttachment: NSTextAttachment {
        
        let content: Attachment.Content
        let layout: Attachment.Layout
        
        let sizingFont: UIFont?
        
        var view: UIView? {
            switch content {
            case .image(_):
                return nil
            case .view(let view):
                return view
            }
        }
        
        init(content: Attachment.Content, layout: Attachment.Layout, sizingFont: UIFont?) {
            self.content = content
            self.layout = layout
            self.sizingFont = sizingFont
            
            super.init(data: nil, ofType: nil)
            
            switch content {
            case .image(let image):
                self.image = image
            case .view(_):
                self.image = UIImage()
            }
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
            attachmentBounds(for: lineFrag)
        }
        
        private func attachmentBounds(for lineFragment: CGRect) -> CGRect {
                    
            var attachmentSize: CGSize
            
            switch layout.sizeMode {
            case .automatic:
                switch content {
                case .image(let image):
                    attachmentSize = image.size
                    
                case .view(let view):
                    if let view = view as? ViewAttachmentSizeProviding {
                        attachmentSize = view.viewAttachmentSize(for: lineFragment)
                        
                    } else {
                        attachmentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                        
                        if attachmentSize.width > lineFragment.width {
                            attachmentSize = view.systemLayoutSizeFitting(CGSize(width: lineFragment.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
                        }
                    }
                }
                
                let ratio = attachmentSize.width / attachmentSize.height
                let width = min(attachmentSize.width, lineFragment.width)
                let height = width / ratio
                attachmentSize = CGSize(width: width, height: height)
                
            case .specified(let size):
                let width = min(size.width, lineFragment.width)
                attachmentSize = CGSize(width: width, height: size.height)
            }
            
            
            let origin: CGPoint

            switch layout.alignment {
            case .center:
                var font: UIFont
                
                if let sizingFont {
                    font = sizingFont
                } else {
                    font = .systemFont(ofSize: 18)
                    let fontSize = font.pointSize / (abs(font.descender) + abs(font.ascender)) * lineFragment.height
                    font = .systemFont(ofSize: fontSize)
                }
                
                // Visual Center
                origin = .init(x: 0, y: (font.capHeight - attachmentSize.height).rounded() / 2)
                
            case .offset(let value):
                origin = value
            }
            
            return .init(origin: origin, size: attachmentSize)
        }
            
    }
}
