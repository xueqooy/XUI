//
//  RichText+Convenience.swift
//  LLPUI
//
//  Created by xueqooy on 2024/6/14.
//

import Foundation
import LLPUtils

public extension RichText {
    
    /// Create a rich text with a title and a detail text.
    static func titleAndDetail(_ title: String, _ detailText: String) -> RichText {
        RTText(title, .foreground(Colors.title), .font(Fonts.body1)) +
        RTLineBreak() +
        RTText(detailText, .foreground(Colors.bodyText1), .font(Fonts.body2))
    }
    
    /** 
     Create a link text with a token to action map.
     
    ```
     RichText.link(NSLocalizedString("If you want to add or remove questions, #edit the original quiz# or &make a copy&.", comment: ""), tokenToActionMap: [
         "#" : editOriginalQuiz,
         "&" : makeACopy
     ])
     ```
     */
    static func link(_ string: String, tokenToActionMap: [String : () -> Void]) -> RichText {
        var result = RTText(string)
        
        tokenToActionMap.forEach { (token, action) in
            // Match text between token
            result
                .addStyles(.foreground(Colors.mediumTeal), .underline(.single), .action(action), checkings: [.regex("\(token)(.*?)\(token)")])
            
            // Remove token
            result
                .addStyles(.font(.systemFont(ofSize: 0)), checkings: [.regex(token)])
        }
        
        return result
    }
    
    static func colorBadge(_ color: UIColor, size: CGSize = .init(width: 14, height: 14), name: String? = nil) -> RichText {
        let colorImage = Icons.roundSquare.withTintColor(color)
        
        return RTOverride {
            RTAttachment(.image(colorImage, .specified(size, .center)))
            
            if let name {
                RTSpace()
                
                name
            }
        }
    }
    
    static func avatarBadge(_ avatarURLConfiguration: AvatarURLConfiguration, size: CGSize = .init(width: 14, height: 14), name: String? = nil) -> RichText {
        let avatarView = AvatarView(size: .unspecified, urlConfiguration: avatarURLConfiguration)
        avatarView.frame = .init(origin: .zero, size: size)
        
        return RTOverride {
            RTAttachment(.view(avatarView, .specified(size, .center)))
            
            if let name {
                RTSpace()
                
                name
            }
        }
    }
}
