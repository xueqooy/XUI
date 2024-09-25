//
//  Icons.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/10/18.
//

import UIKit

public struct Icons {
    public static let popoverArrowUp = generateImage(CGSize(width: 16, height: 10)) { size, context in
        context.move(to: CGPoint(x: (size.width / 2).flatInPixel(), y: 0))
        context.addLine(to: CGPoint(x: 0, y: size.height.flatInPixel()))
        context.addLine(to: CGPoint(x: size.width.flatInPixel(), y: size.height.flatInPixel()))
        context.fillPath()
    }?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public static let dropdown = LLPUIFramework.image(named: "dropdown")
    
    public static let calendar = LLPUIFramework.image(named: "calendar")

    public static let cancel = LLPUIFramework.image(named: "cancel")
    
    public static let alertSuccess = LLPUIFramework.image(named: "alert.success")
    
    public static let alertError = LLPUIFramework.image(named: "alert.error")

    public static let alertNote = LLPUIFramework.image(named: "alert.note")
    
    public static let alertWarning = LLPUIFramework.image(named: "alert.warning")
    
    public static let visibilityOff = LLPUIFramework.image(named: "visibility.off")

    public static let visibilityOn = LLPUIFramework.image(named: "visibility.on")

    public static let checkboxOn = LLPUIFramework.image(named: "checkbox.on")
    
    public static let checkmark = LLPUIFramework.image(named: "checkmark")
    
    public static let checkmarkThick = LLPUIFramework.image(named: "checkmark.thick")
    
    public static let radioOn = generateFilledCircleImage(diameter: 20, color: Colors.teal, strokeColor: .clear ,strokeWidth: 4)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public static let search = LLPUIFramework.image(named: "search")
    
    public static let arrowRight = LLPUIFramework.image(named: "arrow.right")
    
    public static let filter = LLPUIFramework.image(named: "filter")
    
    public static let sort = LLPUIFramework.image(named: "sort")
        
    public static let camera = LLPUIFramework.image(named: "camera")
    
    public static let notification = LLPUIFramework.image(named: "notification")
    
    public static let avatarPlaceholder = LLPUIFramework.image(named: "avatar.placeholder")
    
    public static let document = LLPUIFramework.image(named: "document")
    
    public static let link = LLPUIFramework.image(named: "link")
    
    public static let video = LLPUIFramework.image(named: "video")

    public static let more = LLPUIFramework.image(named: "more")

    public static let gif = LLPUIFramework.image(named: "gif")

    public static let attachment = LLPUIFramework.image(named: "attachment")
        
    public static let mediaGoogleDoc = LLPUIFramework.image(named: "media.google.doc")

    public static let mediaGoogleSheet = LLPUIFramework.image(named: "media.google.sheet")
    
    public static let mediaGoogleSlide = LLPUIFramework.image(named: "media.google.slide")
    
    public static let mediaExcel = LLPUIFramework.image(named: "media.excel")

    public static let mediaPPT = LLPUIFramework.image(named: "media.ppt")

    public static let mediaWord = LLPUIFramework.image(named: "media.word")
    
    public static let mediaPDF = LLPUIFramework.image(named: "media.pdf")
    
    public static let mediaZip = LLPUIFramework.image(named: "media.zip")
    
    public static let mediaLink = LLPUIFramework.image(named: "media.link")
    
    public static let mediaDocument = LLPUIFramework.image(named: "media.document")

    public static let mediaVideo = LLPUIFramework.image(named: "media.video")
    
    public static let mediaAudio = LLPUIFramework.image(named: "media.audio")
    
    public static let mediaUnknown = generateImageWithMargins(image: document, margins: .init(uniformValue: 4)).withRenderingMode(.alwaysTemplate)
    
    public static let library = LLPUIFramework.image(named: "library")

    public static let sketch = LLPUIFramework.image(named: "sketch")
    
    public static let cameraRoll = LLPUIFramework.image(named: "cameraRoll")
    
    public static let likeActive = LLPUIFramework.image(named: "like.active")
    
    public static let likeDeactive = LLPUIFramework.image(named: "like.deactive")
    
    public static let comment = LLPUIFramework.image(named: "comment")
    
    public static let share = LLPUIFramework.image(named: "share")
    
    public static let trash = LLPUIFramework.image(named: "trash")
    
    public static let trashColour = LLPUIFramework.image(named: "trash.colour")
    
    public static let edit = LLPUIFramework.image(named: "edit")
    
    public static let backpack = LLPUIFramework.image(named: "backpack")

    public static let assignment = LLPUIFramework.image(named: "assignment")
    
    public static let group = LLPUIFramework.image(named: "group")
    
    public static let quizColour = LLPUIFramework.image(named: "quiz.colour")
    
    public static let assignmentColour = LLPUIFramework.image(named: "assignment.colour")

    public static let pollColour = LLPUIFramework.image(named: "poll.colour")
    
    public static let wellnessCheckColour = LLPUIFramework.image(named: "wellnessCheck.colour")
    
    public static let refresh = LLPUIFramework.image(named: "refresh")
    
    public static let eventColour = LLPUIFramework.image(named: "event.colour")
    
    public static let message = LLPUIFramework.image(named: "message")
    
    public static let plus = LLPUIFramework.image(named: "plus")

    public static let hudActivity = LLPUIFramework.image(named: "hud.activity")

    public static let roundSquare = generateRectangleImage(size: .square(16), cornerRadius: 4, color: Colors.teal)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public static let verticalBar = generateRectangleImage(size: CGSize(width: 4, height: 16), cornerRadius: 2, color: Colors.teal)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        
    public static let progressThumb = generateImage(CGSize.square(16)) { size, context in
        context.setShadow(offset: .zero, blur: 3.0, color: Colors.shadow.cgColor)
        
        let centerRect = CGRect(x: 3, y: 3, width: 10, height: 10)
        context.setFillColor(UIColor.white.cgColor)
        context.addEllipse(in: centerRect)
        context.drawPath(using: .fill)
    }
    
    public static let hourglass = LLPUIFramework.image(named: "hourglass")
}
