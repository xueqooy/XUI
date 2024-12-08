//
//  MultilineInputField.swift
//  XUI
//
//  Created by xueqooy on 2023/3/10.
//

import UIKit
import Combine

/// An alternative to UITextView
public class MultilineInputField: InputField {
    
    public var isEditable: Bool {
        set {
            (textInput as! TextView).isEditable = newValue
        }
        get {
            (textInput as! TextView).isEditable
        }
    }
    
    public var isSelectable: Bool {
        set {
            (textInput as! TextView).isSelectable = newValue
        }
        get {
            (textInput as! TextView).isSelectable
        }
    }
    
    override public var defaultContentHeight: CGFloat {
        90
    }
    
    /// Preferred text box height, actual height is affected by the height of the text and `allowedAdditionalHeight`
    public lazy var preferredTextInputHeight: CGFloat = defaultContentHeight {
        didSet {
            guard oldValue != preferredTextInputHeight else {
                return
            }
            
            if automaticallyAdjustsAdditionalHeight {
                allowedAdditionalHeight = recommendedAdditionalHeight
            }
            
            updateContentHeight()
        }
    }
    
    /// The actual height is  `(preferredTextInputHeight ... preferredTextInputHeight + allowedAdditionalHeight)`
    public lazy var allowedAdditionalHeight: CGFloat = recommendedAdditionalHeight {
        didSet {
            guard oldValue != allowedAdditionalHeight else {
                return
            }
            
            updateContentHeight()
        }
    }
    
    public var automaticallyAdjustsAdditionalHeight: Bool = true
    
    public var recommendedAdditionalHeight: CGFloat {
        if traitCollection.verticalSizeClass == .regular {
            return (UIScreen.main.bounds.height / 4).rounded(.down)
        }
        return (UIScreen.main.bounds.height / 6).rounded(.down)
    }
    
    private var contentSizeSubscription: AnyCancellable?
    
    public override func makeTextInput() -> TextInput {
        let textView = TextView()
        textView.delegate = self
        contentSizeSubscription = textView.publisher(for: \.contentSize, options: [.new]).sink(receiveValue: { [weak self] contentSize in
            guard let self = self, self.allowedAdditionalHeight > 0  else { return }
        
            self.updateContentHeight()
        })
        return textView
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if automaticallyAdjustsAdditionalHeight, traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass || traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            allowedAdditionalHeight = recommendedAdditionalHeight
        }
    }
    
    private func updateContentHeight() {
        let textView = textInput as! TextView
        
        let fullHeight = textView.contentSize.height + textView.contentInset.vertical
        let minHeight = self.preferredTextInputHeight
        let maxHeight = minHeight + self.allowedAdditionalHeight
        
        self.contentHeight = min(max(minHeight, fullHeight), maxHeight)
    }
}


// MARK: - UITextViewDelegate

extension InputField: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Maybe prevent from inputting whitespace
        if  !allowsWhitespaceInput && text.rangeOfCharacter(from: .whitespaces) != nil {
            return false
        }
        
        // Maybe prevent text from exceeding maximum length
        if maximumTextLength < .max {
            // If the Chinese input method is in the process of inputting Pinyin (marketTextRange is not nil), the word count should not be limited.
            if textView.markedTextRange !=  nil {
                return true
            }
            
            let textLength = (textView.text ?? "").utf16.count
            let replacementTextLength = text.utf16.count
            let rangeLength = range.length

            if NSMaxRange(range) > textLength {
                // If the range exceeds the limit, continuing to return true will cause a crash.
                // The approach here is to return false this time and reduce the range that is out of bounds to a range that is not out of bounds, then manually replace the range
                let updatedRange = NSMakeRange(range.location, range.length - (NSMaxRange(range) - textLength))
                if updatedRange.length > 0 {
                    if let textRange = textView.convertTextRange(from: updatedRange) {
                        textView.replace(textRange, withText: text)
                    }
                }
                return false
            }
            
            if replacementTextLength == 0 && rangeLength > 0 {
                // Allow deletion
                return true
            }
            
            if textLength - rangeLength + replacementTextLength > maximumTextLength {
                // Text exceeds length limit, crop
                
                if textLength - rangeLength == maximumTextLength && text == "\n" {
                    // When the input text reaches the maximum length limit, continuing to click the return button (equivalent to attempting to insert "\n") will consider the total text length to have exceeded the maximum length limit. Therefore, this click on the return button has been intercepted, and the external world cannot perceive the occurrence of this return event. Therefore, special protection has been provided for this situation
                    return false
                }
                
                let substringLength = maximumTextLength - textLength + rangeLength
                if substringLength > 0 && replacementTextLength > substringLength {
                    let allowedString = text.substringAvoidBreakingUpCharacterSequences(with: NSRange(location: 0, length: substringLength), lessValue: true)
                    let allowedStringLength = allowedString.utf16.count
                    if allowedStringLength <= substringLength {
                        textView.text = ((textView.text ?? "") as NSString).replacingCharacters(in: range, with: allowedString)
                        
                        // Modifying the selectedRange on iOS 10 allows the cursor to immediately move to a new position, but iOS 11 and above require a delay for a while
                        let finalSelectedRange = NSRange(location: range.location + allowedStringLength, length: 0)
                        textView.selectedRange = finalSelectedRange
                        DispatchQueue.main.async {
                            textView.selectedRange = finalSelectedRange
                        }
                        
                        // Fire edting change event
                        sendActions(for: .editingChanged)
                    }
                }
                
                return false
            }
        }
        
        return true
    }
}
