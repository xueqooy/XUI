//
//  Icons.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/10/18.
//

import UIKit

public enum Icons {
    public static let popoverArrowUp = generateImage(CGSize(width: 16, height: 10)) { size, context in
        context.move(to: CGPoint(x: (size.width / 2).flatInPixel(), y: 0))
        context.addLine(to: CGPoint(x: 0, y: size.height.flatInPixel()))
        context.addLine(to: CGPoint(x: size.width.flatInPixel(), y: size.height.flatInPixel()))
        context.fillPath()
    }?.withRenderingMode(.alwaysTemplate) ?? UIImage()

    public static let dropdown = XUIFramework.image(named: "dropdown")

    public static let calendar = XUIFramework.image(named: "calendar")

    public static let checkCircle = XUIFramework.image(named: "check.circle")

    public static let noteCircle = XUIFramework.image(named: "note.circle")

    public static let warningCircle = XUIFramework.image(named: "warning.circle")

    public static let warningCircleLarge = XUIFramework.image(named: "warning.circle.large")

    public static let visibilityOff = XUIFramework.image(named: "visibility.off")

    public static let visibilityOn = XUIFramework.image(named: "visibility.on")

    public static let checkboxOn = XUIFramework.image(named: "checkbox.on")

    public static let checkmark = XUIFramework.image(named: "checkmark")

    public static let checkmarkThick = XUIFramework.image(named: "checkmark.thick")

    public static let radioOn = generateFilledCircleImage(diameter: 20, color: Colors.teal, strokeColor: .clear, strokeWidth: 4)?.withRenderingMode(.alwaysTemplate) ?? UIImage()

    public static let search = XUIFramework.image(named: "search")

    public static let arrowRight = XUIFramework.image(named: "arrow.right")

    public static let arrowBack = XUIFramework.image(named: "arrow.back")

    public static let filter = XUIFramework.image(named: "filter")

    public static let sort = XUIFramework.image(named: "sort")

    public static let camera = XUIFramework.image(named: "camera")

    public static let notification = XUIFramework.image(named: "notification")

    public static let avatarPlaceholder = XUIFramework.image(named: "avatar.placeholder")

    public static let document = XUIFramework.image(named: "document")

    public static let link = XUIFramework.image(named: "link")

    public static let video = XUIFramework.image(named: "video")

    public static let videoCamera = XUIFramework.image(named: "video.camera")

    public static let audioHeadphones = XUIFramework.image(named: "audio.headphones")

    public static let more = XUIFramework.image(named: "more")

    public static let gif = XUIFramework.image(named: "gif")

    public static let attachment = XUIFramework.image(named: "attachment")

    public static let mediaGoogleDoc = XUIFramework.image(named: "media.google.doc")

    public static let mediaGoogleSheet = XUIFramework.image(named: "media.google.sheet")

    public static let mediaGoogleSlide = XUIFramework.image(named: "media.google.slide")

    public static let mediaExcel = XUIFramework.image(named: "media.excel")

    public static let mediaPPT = XUIFramework.image(named: "media.ppt")

    public static let mediaWord = XUIFramework.image(named: "media.word")

    public static let mediaPDF = XUIFramework.image(named: "media.pdf")

    public static let mediaZip = XUIFramework.image(named: "media.zip")

    public static let mediaLink = XUIFramework.image(named: "media.link")

    public static let mediaDocument = XUIFramework.image(named: "media.document")

    public static let mediaVideo = XUIFramework.image(named: "media.video")

    public static let mediaAudio = XUIFramework.image(named: "media.audio")

    public static let mediaUnknown = generateImageWithMargins(image: document, margins: .init(uniformValue: 4)).withRenderingMode(.alwaysTemplate)

    public static let library = XUIFramework.image(named: "library")

    public static let sketch = XUIFramework.image(named: "sketch")

    public static let cameraRoll = XUIFramework.image(named: "cameraRoll")

    public static let likeActive = XUIFramework.image(named: "like.active")

    public static let likeDeactive = XUIFramework.image(named: "like.deactive")

    public static let comment = XUIFramework.image(named: "comment")

    public static let share = XUIFramework.image(named: "share")

    public static let trash = XUIFramework.image(named: "trash")

    public static let trashColour = XUIFramework.image(named: "trash.colour")

    public static let edit = XUIFramework.image(named: "edit")

    public static let backpack = XUIFramework.image(named: "backpack")

    public static let assignment = XUIFramework.image(named: "assignment")

    public static let group = XUIFramework.image(named: "group")

    public static let quizColour = XUIFramework.image(named: "quiz.colour")

    public static let assignmentColour = XUIFramework.image(named: "assignment.colour")

    public static let pollColour = XUIFramework.image(named: "poll.colour")

    public static let wellnessCheckColour = XUIFramework.image(named: "wellnessCheck.colour")

    public static let refresh = XUIFramework.image(named: "refresh")

    public static let eventColour = XUIFramework.image(named: "event.colour")

    public static let message = XUIFramework.image(named: "message")

    public static let plus = XUIFramework.image(named: "plus")

    public static let hudActivity = XUIFramework.image(named: "hud.activity")

    public static let roundSquare = generateRectangleImage(size: .square(16), cornerRadius: 4, color: Colors.teal)?.withRenderingMode(.alwaysTemplate) ?? UIImage()

    public static let verticalBar = generateRectangleImage(size: CGSize(width: 4, height: 16), cornerRadius: 2, color: Colors.teal)?.withRenderingMode(.alwaysTemplate) ?? UIImage()

    public static let progressThumb = generateImage(CGSize.square(16)) { _, context in
        context.setShadow(offset: .zero, blur: 3.0, color: Colors.shadow.cgColor)

        let centerRect = CGRect(x: 3, y: 3, width: 10, height: 10)
        context.setFillColor(UIColor.white.cgColor)
        context.addEllipse(in: centerRect)
        context.drawPath(using: .fill)
    }

    public static let progressThumbSmall = generateImage(CGSize.square(10)) { _, context in
        context.setShadow(offset: .zero, blur: 2.0, color: Colors.shadow.cgColor)

        let centerRect = CGRect(x: 2, y: 2, width: 6, height: 6)
        context.setFillColor(UIColor.white.cgColor)
        context.addEllipse(in: centerRect)
        context.drawPath(using: .fill)
    }

    public static let hourglass = XUIFramework.image(named: "hourglass")

    public static let xmark = XUIFramework.image(named: "xmark")

    public static let xmarkSmall = XUIFramework.image(named: "xmark.small")

    public static let menu = XUIFramework.image(named: "menu")

    public static let brokenImage = XUIFramework.image(named: "broken.image")

    public static let coverPlaceholder = generateImageWithMargins(image: Icons.brokenImage, margins: .init(top: 68, left: 136, bottom: 68, right: 136))

    public static let books = XUIFramework.image(named: "books")

    public static let booksLarge = XUIFramework.image(named: "books.large")

    public static let warningWave = generateWaveImage(with: Icons.warningCircleLarge)

    public static let booksWave = generateWaveImage(with: Icons.booksLarge)

    public static let play = XUIFramework.image(named: "play")

    public static let pause = XUIFramework.image(named: "pause")

    public static let speakerOn = XUIFramework.image(named: "speaker.on")

    public static let speakerOff = XUIFramework.image(named: "speaker.off")

    public static let expand = XUIFramework.image(named: "expand")

    public static let collapse = XUIFramework.image(named: "collapse")

    private static func generateWaveImage(with image: UIImage) -> UIImage {
        let radii: [CGFloat] = [77, 108, 144]
        let colors = [Colors.extraLightTeal, Colors.lightTeal, Colors.teal]
        let maxRadius = radii.last!
        let center = CGPoint(x: maxRadius, y: maxRadius)
        let imageSize: CGSize = .square(48)
        let imageColor = colors[1]

        return generateImage(.square(maxRadius * 2), flipped: true) { _, context in
            for (index, radius) in radii.reversed().enumerated() {
                context.setFillColor(colors[index].cgColor)
                context.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
                context.fillPath()
            }

            if let mask = image.cgImage {
                let imageRect = CGRect(origin: .init(x: center.x - imageSize.width / 2, y: center.y - imageSize.height / 2), size: imageSize)

                context.setFillColor(imageColor.cgColor)
                context.clip(to: imageRect, mask: mask)
                context.fill(imageRect)
            }

        } ?? UIImage()
    }
}
