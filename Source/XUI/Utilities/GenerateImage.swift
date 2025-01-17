//
//  GenerateImage.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/9/22.
//

import Accelerate
import CoreMedia
import Foundation
import UIKit

public let deviceColorSpace: CGColorSpace = {
    if let colorSpace = CGColorSpace(name: CGColorSpace.displayP3) {
        return colorSpace
    } else {
        return CGColorSpaceCreateDeviceRGB()
    }
}()

private let grayscaleColorSpace = CGColorSpaceCreateDeviceGray()

let deviceScale = UIScreen.main.scale

public func generateImagePixel(_ size: CGSize, scale: CGFloat, pixelGenerator: (CGSize, UnsafeMutablePointer<UInt8>, Int) -> Void) -> UIImage? {
    let context = DrawingContext(size: size, scale: scale, opaque: false, clear: false)
    pixelGenerator(CGSize(width: size.width * scale, height: size.height * scale), context.bytes.assumingMemoryBound(to: UInt8.self), context.bytesPerRow)
    return context.generateImage()
}

private func withImageBytes(image: UIImage, _ f: (UnsafePointer<UInt8>, Int, Int, Int) -> Void) {
    let selectedScale = image.scale
    let scaledSize = CGSize(width: image.size.width * selectedScale, height: image.size.height * selectedScale)
    let bytesPerRow = DeviceGraphicsContextSettings.shared.bytesPerRow(forWidth: Int(scaledSize.width))
    let length = bytesPerRow * Int(scaledSize.height)
    let bytes = malloc(length)!.assumingMemoryBound(to: UInt8.self)
    memset(bytes, 0, length)

    let bitmapInfo = DeviceGraphicsContextSettings.shared.transparentBitmapInfo

    guard let context = CGContext(data: bytes, width: Int(scaledSize.width), height: Int(scaledSize.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: deviceColorSpace, bitmapInfo: bitmapInfo.rawValue) else {
        return
    }

    context.scaleBy(x: selectedScale, y: selectedScale)
    context.draw(image.cgImage!, in: CGRect(origin: CGPoint(), size: image.size))

    f(bytes, Int(scaledSize.width), Int(scaledSize.height), bytesPerRow)
}

public func generateGrayscaleAlphaMaskImage(image: UIImage) -> UIImage? {
    let selectedScale = image.scale
    let scaledSize = CGSize(width: image.size.width * selectedScale, height: image.size.height * selectedScale)
    let bytesPerRow = (1 * Int(scaledSize.width) + 31) & ~31
    let length = bytesPerRow * Int(scaledSize.height)
    let bytes = malloc(length)!.assumingMemoryBound(to: UInt8.self)
    memset(bytes, 0, length)

    guard let provider = CGDataProvider(dataInfo: bytes, data: bytes, size: length, releaseData: { bytes, _, _ in
        free(bytes)
    })
    else {
        return nil
    }

    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

    guard let context = CGContext(data: bytes, width: Int(scaledSize.width), height: Int(scaledSize.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: grayscaleColorSpace, bitmapInfo: bitmapInfo.rawValue) else {
        return nil
    }

    context.scaleBy(x: selectedScale, y: selectedScale)

    withImageBytes(image: image) { pixels, width, height, imageBytesPerRow in
        var src = vImage_Buffer(data: UnsafeMutableRawPointer(mutating: pixels), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: imageBytesPerRow)

        let permuteMap: [UInt8] = [3, 2, 1, 0]
        vImagePermuteChannels_ARGB8888(&src, &src, permuteMap, vImage_Flags(kvImageDoNotTile))
        vImageUnpremultiplyData_ARGB8888(&src, &src, vImage_Flags(kvImageDoNotTile))

        for y in 0 ..< Int(scaledSize.height) {
            let srcRowBytes = pixels.advanced(by: y * imageBytesPerRow)
            let dstRowBytes = bytes.advanced(by: y * bytesPerRow)
            for x in 0 ..< Int(scaledSize.width) {
                let a = srcRowBytes.advanced(by: x * 4 + 0).pointee
                dstRowBytes.advanced(by: x).pointee = 0xFF &- a
            }
        }
    }

    guard let image = CGImage(width: Int(scaledSize.width), height: Int(scaledSize.height), bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: bytesPerRow, space: grayscaleColorSpace, bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    else {
        return nil
    }

    return UIImage(cgImage: image, scale: selectedScale, orientation: .up)
}

public func generateImage(_ size: CGSize, opaque: Bool = false, scale: CGFloat? = nil, flipped: Bool = false, contextGenerator: (CGSize, CGContext) -> Void) -> UIImage? {
    if size.width.isZero || size.height.isZero {
        return nil
    }
    let context = DrawingContext(size: size, scale: scale ?? 0.0, opaque: opaque, clear: true)
    if flipped {
        context.withFlippedContext { c in
            contextGenerator(context.size, c)
        }
    } else {
        context.withContext { c in
            contextGenerator(context.size, c)
        }
    }
    return context.generateImage()
}

public func generateRectangleImage(size: CGSize, cornerRadius: CGFloat, color: UIColor? = nil) -> UIImage? {
    return generateImage(size, contextGenerator: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))

        let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius)

        context.addPath(path.cgPath)
        if let color {
            context.setFillColor(color.cgColor)
        }
        context.fillPath()
    })
}

public func generateFilledCircleImage(diameter: CGFloat, color: UIColor?, strokeColor: UIColor? = nil, strokeWidth: CGFloat? = nil, backgroundColor: UIColor? = nil) -> UIImage? {
    return generateImage(CGSize(width: diameter, height: diameter), contextGenerator: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        if let backgroundColor = backgroundColor {
            context.setFillColor(backgroundColor.cgColor)
            context.fill(CGRect(origin: CGPoint(), size: size))
        }

        if let strokeColor = strokeColor, let strokeWidth = strokeWidth {
            context.setFillColor(strokeColor.cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(), size: size))

            if let color = color {
                context.setFillColor(color.cgColor)
            } else {
                context.setFillColor(UIColor.clear.cgColor)
                context.setBlendMode(.copy)
            }
            context.fillEllipse(in: CGRect(origin: CGPoint(x: strokeWidth, y: strokeWidth), size: CGSize(width: size.width - strokeWidth * 2.0, height: size.height - strokeWidth * 2.0)))
        } else {
            if let color = color {
                context.setFillColor(color.cgColor)
            } else {
                context.setFillColor(UIColor.clear.cgColor)
                context.setBlendMode(.copy)
            }
            context.fillEllipse(in: CGRect(origin: CGPoint(), size: size))
        }

        context.setShadow(offset: CGSize(width: 2, height: 2), blur: 4, color: UIColor.gray.cgColor)
    })
}

public func generateAdjustedStretchableFilledCircleImage(diameter: CGFloat, color: UIColor) -> UIImage? {
    let corner: CGFloat = diameter / 2.0
    return generateImage(CGSize(width: diameter + 2.0, height: diameter + 2.0), contextGenerator: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        context.setFillColor(color.cgColor)
        context.move(to: CGPoint(x: 0.0, y: corner))
        context.addArc(tangent1End: CGPoint(x: 0.0, y: 0.0), tangent2End: CGPoint(x: corner, y: 0.0), radius: corner)
        context.addLine(to: CGPoint(x: size.width - corner, y: 0.0))
        context.addArc(tangent1End: CGPoint(x: size.width, y: 0.0), tangent2End: CGPoint(x: size.width, y: corner), radius: corner)
        context.addLine(to: CGPoint(x: size.width, y: size.height - corner))
        context.addArc(tangent1End: CGPoint(x: size.width, y: size.height), tangent2End: CGPoint(x: size.width - corner, y: size.height), radius: corner)
        context.addLine(to: CGPoint(x: corner, y: size.height))
        context.addArc(tangent1End: CGPoint(x: 0.0, y: size.height), tangent2End: CGPoint(x: 0.0, y: size.height - corner), radius: corner)
        context.closePath()
        context.fillPath()
    })?.stretchableImage(withLeftCapWidth: Int(diameter / 2) + 1, topCapHeight: Int(diameter / 2) + 1)
}

public func generateCircleImage(diameter: CGFloat, lineWidth: CGFloat, color: UIColor?, backgroundColor: UIColor? = nil) -> UIImage? {
    return generateImage(CGSize(width: diameter, height: diameter), contextGenerator: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        if let backgroundColor = backgroundColor {
            context.setFillColor(backgroundColor.cgColor)
            context.fill(CGRect(origin: CGPoint(), size: size))
        }

        if let color = color {
            context.setStrokeColor(color.cgColor)
        } else {
            context.setStrokeColor(UIColor.clear.cgColor)
            context.setBlendMode(.copy)
        }
        context.setLineWidth(lineWidth)
        context.strokeEllipse(in: CGRect(origin: CGPoint(x: lineWidth / 2.0, y: lineWidth / 2.0), size: CGSize(width: size.width - lineWidth, height: size.height - lineWidth)))
    })
}

public func generateStretchableFilledCircleImage(radius: CGFloat, color: UIColor?, backgroundColor: UIColor? = nil) -> UIImage? {
    let intRadius = Int(radius)
    let cap = intRadius == 1 ? 2 : intRadius
    return generateFilledCircleImage(diameter: radius * 2.0, color: color, backgroundColor: backgroundColor)?.stretchableImage(withLeftCapWidth: cap, topCapHeight: cap)
}

public func generateStretchableFilledCircleImage(diameter: CGFloat, color: UIColor?, strokeColor: UIColor? = nil, strokeWidth: CGFloat? = nil, backgroundColor: UIColor? = nil) -> UIImage? {
    let intRadius = Int(diameter / 2.0)
    let intDiameter = Int(diameter)
    let cap: Int
    if intDiameter == 3 {
        cap = 1
    } else if intDiameter == 2 {
        cap = 3
    } else if intRadius == 1 {
        cap = 2
    } else {
        cap = intRadius
    }

    return generateFilledCircleImage(diameter: diameter, color: color, strokeColor: strokeColor, strokeWidth: strokeWidth, backgroundColor: backgroundColor)?.stretchableImage(withLeftCapWidth: cap, topCapHeight: cap)
}

public func generateVerticallyStretchableFilledCircleImage(radius: CGFloat, color: UIColor?, backgroundColor: UIColor? = nil) -> UIImage? {
    return generateImage(CGSize(width: radius * 2.0, height: radius * 2.0 + radius), contextGenerator: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        if let backgroundColor = backgroundColor {
            context.setFillColor(backgroundColor.cgColor)
            context.fill(CGRect(origin: CGPoint(), size: size))
        }

        if let color = color {
            context.setFillColor(color.cgColor)
        } else {
            context.setFillColor(UIColor.clear.cgColor)
            context.setBlendMode(.copy)
        }
        context.fillEllipse(in: CGRect(origin: CGPoint(), size: CGSize(width: radius + radius, height: radius + radius)))
        context.fillEllipse(in: CGRect(origin: CGPoint(x: 0.0, y: radius), size: CGSize(width: radius + radius, height: radius + radius)))
    })?.stretchableImage(withLeftCapWidth: Int(radius), topCapHeight: Int(radius))
}

public func generateSmallHorizontalStretchableFilledCircleImage(diameter: CGFloat, color: UIColor?, backgroundColor: UIColor? = nil) -> UIImage? {
    return generateImage(CGSize(width: diameter + 1.0, height: diameter), contextGenerator: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))

        if let subImage = generateImage(CGSize(width: diameter + 1.0, height: diameter), contextGenerator: { size, context in
            context.clear(CGRect(origin: CGPoint(), size: size))
            context.setFillColor(UIColor.black.cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(), size: CGSize(width: diameter, height: diameter)))
            context.fill(CGRect(origin: CGPoint(x: diameter / 2.0, y: 0.0), size: CGSize(width: 1.0, height: diameter)))
            context.fillEllipse(in: CGRect(origin: CGPoint(x: 1.0, y: 0.0), size: CGSize(width: diameter, height: diameter)))
        }) {
            if let backgroundColor = backgroundColor {
                context.setFillColor(backgroundColor.cgColor)
                context.fill(CGRect(origin: CGPoint(), size: size))
            }

            if let color = color {
                context.setFillColor(color.cgColor)
            } else {
                context.setFillColor(UIColor.clear.cgColor)
                context.setBlendMode(.copy)
            }

            context.clip(to: CGRect(origin: CGPoint(), size: size), mask: subImage.cgImage!)
            context.fill(CGRect(origin: CGPoint(), size: size))
        }
    })?.stretchableImage(withLeftCapWidth: Int(diameter / 2), topCapHeight: Int(diameter / 2))
}

public func generateTintedImage(image: UIImage?, color: UIColor, backgroundColor: UIColor? = nil) -> UIImage? {
    guard let image = image else {
        return nil
    }

    let imageSize = image.size

    UIGraphicsBeginImageContextWithOptions(imageSize, backgroundColor != nil, image.scale)
    if let context = UIGraphicsGetCurrentContext() {
        if let backgroundColor = backgroundColor {
            context.setFillColor(backgroundColor.cgColor)
            context.fill(CGRect(origin: CGPoint(), size: imageSize))
        }

        let imageRect = CGRect(origin: CGPoint(), size: imageSize)
        context.saveGState()
        context.translateBy(x: imageRect.midX, y: imageRect.midY)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: -imageRect.midX, y: -imageRect.midY)
        context.clip(to: imageRect, mask: image.cgImage!)
        context.setFillColor(color.cgColor)
        context.fill(imageRect)
        context.restoreGState()
    }

    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return tintedImage
}

public func generateGradientTintedImage(image: UIImage?, colors: [UIColor]) -> UIImage? {
    guard let image = image else {
        return nil
    }

    let imageSize = image.size

    UIGraphicsBeginImageContextWithOptions(imageSize, false, image.scale)
    if let context = UIGraphicsGetCurrentContext() {
        let imageRect = CGRect(origin: CGPoint(), size: imageSize)
        context.saveGState()
        context.translateBy(x: imageRect.midX, y: imageRect.midY)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: -imageRect.midX, y: -imageRect.midY)
        context.clip(to: imageRect, mask: image.cgImage!)

        if colors.count >= 2 {
            let gradientColors = colors.map { $0.cgColor } as CFArray

            var locations: [CGFloat] = []
            for i in 0 ..< colors.count {
                let t = CGFloat(i) / CGFloat(colors.count - 1)
                locations.append(t)
            }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: &locations)!

            context.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: imageRect.height), end: CGPoint(x: 0.0, y: 0.0), options: CGGradientDrawingOptions())
        } else if !colors.isEmpty {
            context.setFillColor(colors[0].cgColor)
            context.fill(imageRect)
        }

        context.restoreGState()
    }

    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return tintedImage
}

public enum GradientImageDirection {
    case vertical
    case horizontal
}

public func generateGradientImage(size: CGSize, colors: [UIColor], locations: [CGFloat], direction: GradientImageDirection = .vertical) -> UIImage? {
    guard colors.count == locations.count else {
        return nil
    }
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    if let context = UIGraphicsGetCurrentContext() {
        let gradientColors = colors.map { $0.cgColor } as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        var locations = locations
        let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: &locations)!

        context.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: 0.0), end: direction == .horizontal ? CGPoint(x: size.width, y: 0.0) : CGPoint(x: 0.0, y: size.height), options: CGGradientDrawingOptions())
    }

    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return image
}

public func generateScaledImage(image: UIImage?, size: CGSize, opaque: Bool = true, scale: CGFloat? = nil, mode: UIView.ContentMode = .scaleToFill) -> UIImage? {
    guard let image = image else {
        return nil
    }

    return generateImage(size, opaque: opaque, scale: scale, contextGenerator: { size, context in
        if !opaque {
            context.clear(CGRect(origin: CGPoint(), size: size))
        }
        let rect = CGRect(origin: CGPoint(), size: size).fit(size: image.size, mode: mode)
        context.draw(image.cgImage!, in: rect)
    })
}

public func generateSingleColorImage(color: UIColor, size: CGSize) -> UIImage? {
    return generateImage(size, contextGenerator: { size, context in
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: CGPoint(), size: size))
    })
}

public func generateImageWithMargins(image: UIImage, margins: UIEdgeInsets) -> UIImage {
    let newImageSize = CGSize(
        width: image.size.width + margins.horizontal,
        height: image.size.height + margins.vertical
    )
    return generateImage(newImageSize, flipped: true) { _, context in
        context.draw(image.cgImage!, in: .init(x: margins.left, y: margins.top, width: image.size.width, height: image.size.height))
    }!
}

public func getSharedDevideGraphicsContextSettings() -> DeviceGraphicsContextSettings {
    struct OpaqueSettings {
        let rowAlignment: Int
        let bitsPerPixel: Int
        let bitsPerComponent: Int
        let opaqueBitmapInfo: CGBitmapInfo
        let colorSpace: CGColorSpace

        init(context: CGContext) {
            rowAlignment = context.bytesPerRow
            bitsPerPixel = context.bitsPerPixel
            bitsPerComponent = context.bitsPerComponent
            opaqueBitmapInfo = context.bitmapInfo
            if UIScreen.main.traitCollection.displayGamut == .P3 {
                colorSpace = CGColorSpace(name: CGColorSpace.displayP3) ?? context.colorSpace!
            } else {
                colorSpace = context.colorSpace!
            }

//            assert(self.rowAlignment == 32)
//            assert(self.bitsPerPixel == 32)
//            assert(self.bitsPerComponent == 8)
        }
    }

    struct TransparentSettings {
        let transparentBitmapInfo: CGBitmapInfo

        init(context: CGContext) {
            transparentBitmapInfo = context.bitmapInfo
        }
    }

    var opaqueSettings: OpaqueSettings?
    var transparentSettings: TransparentSettings?

    let opaqueFormat = UIGraphicsImageRendererFormat()
    let transparentFormat = UIGraphicsImageRendererFormat()
    opaqueFormat.preferredRange = .standard
    transparentFormat.preferredRange = .standard
    opaqueFormat.opaque = true
    transparentFormat.opaque = false

    let opaqueRenderer = UIGraphicsImageRenderer(bounds: CGRect(origin: CGPoint(), size: CGSize(width: 1.0, height: 1.0)), format: opaqueFormat)
    let _ = opaqueRenderer.image(actions: { context in
        opaqueSettings = OpaqueSettings(context: context.cgContext)
    })

    let transparentRenderer = UIGraphicsImageRenderer(bounds: CGRect(origin: CGPoint(), size: CGSize(width: 1.0, height: 1.0)), format: transparentFormat)
    let _ = transparentRenderer.image(actions: { context in
        transparentSettings = TransparentSettings(context: context.cgContext)
    })

    return DeviceGraphicsContextSettings(
        rowAlignment: opaqueSettings!.rowAlignment,
        bitsPerPixel: opaqueSettings!.bitsPerPixel,
        bitsPerComponent: opaqueSettings!.bitsPerComponent,
        opaqueBitmapInfo: opaqueSettings!.opaqueBitmapInfo,
        transparentBitmapInfo: transparentSettings!.transparentBitmapInfo,
        colorSpace: opaqueSettings!.colorSpace
    )
}

public struct DeviceGraphicsContextSettings {
    public static let shared: DeviceGraphicsContextSettings = getSharedDevideGraphicsContextSettings()

    public let rowAlignment: Int
    public let bitsPerPixel: Int
    public let bitsPerComponent: Int
    public let opaqueBitmapInfo: CGBitmapInfo
    public let transparentBitmapInfo: CGBitmapInfo
    public let colorSpace: CGColorSpace

    public func bytesPerRow(forWidth width: Int) -> Int {
        let baseValue = bitsPerPixel * width / 8
        return (baseValue + 31) & ~0x1F
    }
}

private class ImageBuffer {
    private(set) var mutableBytes: UnsafeMutableRawPointer

    private let length: Int
    private var createdData: Bool = false

    init(length: Int) {
        self.length = length
        mutableBytes = malloc(length)
    }

    deinit {
        if createdData == false {
            mutableBytes.deallocate()
        }
    }

    func createDataProviderAndInvalidate() -> CGDataProvider? {
        assert(!createdData, "Should not create data provider from buffer multiple times.")
        createdData = true

        let data = Data(bytesNoCopy: mutableBytes, count: length, deallocator: .custom { bytes, _ in
            bytes.deallocate()
        }) as CFData
        return CGDataProvider(data: data)
    }
}

public class DrawingContext {
    public enum BltMode {
        case Alpha
    }

    public let size: CGSize
    public let scale: CGFloat
    private let scaledSize: CGSize
    public let bytesPerRow: Int
    private let bitmapInfo: CGBitmapInfo
    public let length: Int
    private let imageBuffer: ImageBuffer
    public var bytes: UnsafeMutableRawPointer {
        if hasGeneratedImage {
            assertionFailure()
        }
        return imageBuffer.mutableBytes
    }

    private let context: CGContext

    private var hasGeneratedImage = false

    public func withContext(_ f: (CGContext) -> Void) {
        let context = self.context

        context.translateBy(x: size.width / 2.0, y: size.height / 2.0)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: -size.width / 2.0, y: -size.height / 2.0)

        f(context)

        context.translateBy(x: size.width / 2.0, y: size.height / 2.0)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: -size.width / 2.0, y: -size.height / 2.0)
    }

    public func withFlippedContext(_ f: (CGContext) -> Void) {
        f(context)
    }

    public init(size: CGSize, scale: CGFloat = 0.0, opaque: Bool = false, clear: Bool = false) {
        assert(!size.width.isZero && !size.height.isZero)
        let size = CGSize(width: max(1.0, size.width), height: max(1.0, size.height))

        let actualScale: CGFloat
        if scale.isZero {
            actualScale = deviceScale
        } else {
            actualScale = scale
        }
        self.size = size
        self.scale = actualScale
        scaledSize = CGSize(width: size.width * actualScale, height: size.height * actualScale)

        bytesPerRow = DeviceGraphicsContextSettings.shared.bytesPerRow(forWidth: Int(scaledSize.width))
        length = bytesPerRow * Int(scaledSize.height)

        imageBuffer = ImageBuffer(length: length)

        if opaque {
            bitmapInfo = DeviceGraphicsContextSettings.shared.opaqueBitmapInfo
        } else {
            bitmapInfo = DeviceGraphicsContextSettings.shared.transparentBitmapInfo
        }

        context = CGContext(
            data: imageBuffer.mutableBytes,
            width: Int(scaledSize.width),
            height: Int(scaledSize.height),
            bitsPerComponent: DeviceGraphicsContextSettings.shared.bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: DeviceGraphicsContextSettings.shared.colorSpace,
            bitmapInfo: bitmapInfo.rawValue,
            releaseCallback: nil,
            releaseInfo: nil
        )!
        context.scaleBy(x: self.scale, y: self.scale)

        if clear {
            memset(bytes, 0, length)
        }
    }

    public func generateImage() -> UIImage? {
        if scaledSize.width.isZero || scaledSize.height.isZero {
            return nil
        }
        if hasGeneratedImage {
            assertionFailure()
//            preconditionFailure()
        }
        hasGeneratedImage = true

        if let dataProvider = imageBuffer.createDataProviderAndInvalidate() {
            if let image = CGImage(
                width: Int(scaledSize.width),
                height: Int(scaledSize.height),
                bitsPerComponent: context.bitsPerComponent,
                bitsPerPixel: context.bitsPerPixel,
                bytesPerRow: context.bytesPerRow,
                space: DeviceGraphicsContextSettings.shared.colorSpace,
                bitmapInfo: context.bitmapInfo,
                provider: dataProvider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
            ) {
                return UIImage(cgImage: image, scale: scale, orientation: .up)
            } else {
                return nil
            }
        }

        return nil
    }

    public func generatePixelBuffer() -> CVPixelBuffer? {
        if scaledSize.width.isZero || scaledSize.height.isZero {
            return nil
        }
        if hasGeneratedImage {
            assertionFailure()
//            preconditionFailure()
        }

        let ioSurfaceProperties = NSMutableDictionary()
        let options = NSMutableDictionary()
        options.setObject(ioSurfaceProperties, forKey: kCVPixelBufferIOSurfacePropertiesKey as NSString)

        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreateWithBytes(nil, Int(scaledSize.width), Int(scaledSize.height), kCVPixelFormatType_32BGRA, bytes, bytesPerRow, { pointer, _ in
            if let pointer = pointer {
                Unmanaged<ImageBuffer>.fromOpaque(pointer).release()
            }
        }, Unmanaged.passRetained(imageBuffer).toOpaque(), options as CFDictionary, &pixelBuffer)

        hasGeneratedImage = true

        return pixelBuffer
    }

    public func colorAt(_ point: CGPoint) -> UIColor {
        let x = Int(point.x * scale)
        let y = Int(point.y * scale)
        if x >= 0 && x < Int(scaledSize.width) && y >= 0 && y < Int(scaledSize.height) {
            let srcLine = bytes.advanced(by: y * bytesPerRow).assumingMemoryBound(to: UInt32.self)
            let pixel = srcLine + x
            let rgb = UInt32(pixel.pointee)
            return UIColor(red: CGFloat((rgb >> 16) & 0xFF) / 255.0, green: CGFloat((rgb >> 8) & 0xFF) / 255.0, blue: CGFloat(rgb & 0xFF) / 255.0, alpha: 1.0)
        } else {
            return UIColor.clear
        }
    }

    public func blt(_ other: DrawingContext, at: CGPoint, mode: DrawingContext.BltMode = .Alpha) {
        if abs(other.scale - scale) < CGFloat.ulpOfOne {
            let srcX = 0
            var srcY = 0
            let dstX = Int(at.x * scale)
            var dstY = Int(at.y * scale)
            if dstX < 0 || dstY < 0 {
                return
            }

            let width = min(Int(size.width * scale) - dstX, Int(other.size.width * scale))
            let height = min(Int(size.height * scale) - dstY, Int(other.size.height * scale))

            let maxDstX = dstX + width
            let maxDstY = dstY + height

            switch mode {
            case .Alpha:
                while dstY < maxDstY {
                    let srcLine = other.bytes.advanced(by: max(0, srcY) * other.bytesPerRow).assumingMemoryBound(to: UInt32.self)
                    let dstLine = bytes.advanced(by: max(0, dstY) * bytesPerRow).assumingMemoryBound(to: UInt32.self)

                    var dx = dstX
                    var sx = srcX
                    while dx < maxDstX {
                        let srcPixel = srcLine + sx
                        let dstPixel = dstLine + dx

                        let baseColor = dstPixel.pointee
                        let baseAlpha = (baseColor >> 24) & 0xFF
                        let baseR = (baseColor >> 16) & 0xFF
                        let baseG = (baseColor >> 8) & 0xFF
                        let baseB = baseColor & 0xFF

                        let alpha = min(baseAlpha, srcPixel.pointee >> 24)

                        let r = (baseR * alpha) / 255
                        let g = (baseG * alpha) / 255
                        let b = (baseB * alpha) / 255

                        dstPixel.pointee = (alpha << 24) | (r << 16) | (g << 8) | b

                        dx += 1
                        sx += 1
                    }

                    dstY += 1
                    srcY += 1
                }
            }
        }
    }
}

public extension UIImage {
    var cvPixelBuffer: CVPixelBuffer? {
        guard let cgImage = cgImage else {
            return nil
        }
        _ = cgImage

        var maybePixelBuffer: CVPixelBuffer?
        let ioSurfaceProperties = NSMutableDictionary()
        let options = NSMutableDictionary()
        options.setObject(ioSurfaceProperties, forKey: kCVPixelBufferIOSurfacePropertiesKey as NSString)

        _ = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width * scale), Int(size.height * scale), kCVPixelFormatType_32ARGB, options as CFDictionary, &maybePixelBuffer)
        guard let pixelBuffer = maybePixelBuffer else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        }

        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)

        let context = CGContext(
            data: baseAddress,
            width: Int(size.width * scale),
            height: Int(size.height * scale),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue,
            releaseCallback: nil,
            releaseInfo: nil
        )!
        context.clear(CGRect(origin: .zero, size: CGSize(width: size.width * scale, height: size.height * scale)))
        context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: size.width * scale, height: size.height * scale)))

        return pixelBuffer
    }

    var cmSampleBuffer: CMSampleBuffer? {
        guard let pixelBuffer = cvPixelBuffer else {
            return nil
        }
        var newSampleBuffer: CMSampleBuffer?

        var timingInfo = CMSampleTimingInfo(
            duration: CMTimeMake(value: 1, timescale: 30),
            presentationTimeStamp: CMTimeMake(value: 0, timescale: 30),
            decodeTimeStamp: CMTimeMake(value: 0, timescale: 30)
        )

        var videoInfo: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer, formatDescriptionOut: &videoInfo)
        guard let videoInfo = videoInfo else {
            return nil
        }
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: videoInfo, sampleTiming: &timingInfo, sampleBufferOut: &newSampleBuffer)

        if let newSampleBuffer = newSampleBuffer {
            let attachments = CMSampleBufferGetSampleAttachmentsArray(newSampleBuffer, createIfNecessary: true)! as NSArray
            let dict = attachments[0] as! NSMutableDictionary

            dict.setValue(kCFBooleanTrue as AnyObject, forKey: kCMSampleAttachmentKey_DisplayImmediately as NSString as String)
        }

        return newSampleBuffer
    }
}

public enum ParsingError: Error {
    case Generic
}

public func readSvgValue(_ index: inout UnsafePointer<UInt8>, end: UnsafePointer<UInt8>, separator: UInt8) throws -> CGFloat {
    let begin = index
    var seenPoint = false
    while index <= end {
        let c = index.pointee
        index = index.successor()

        if c == 46 { // .
            if seenPoint {
                throw ParsingError.Generic
            } else {
                seenPoint = true
            }
        } else if c == separator {
            break
        } else if !((c >= 48 && c <= 57) || c == 45 || c == 101 || c == 69) {
            throw ParsingError.Generic
        }
    }

    if index == begin {
        throw ParsingError.Generic
    }

    if let value = NSString(bytes: UnsafeRawPointer(begin), length: index - begin, encoding: String.Encoding.utf8.rawValue)?.floatValue {
        return CGFloat(value)
    } else {
        throw ParsingError.Generic
    }
}

public func drawSvgPath(_ context: CGContext, path: StaticString, strokeOnMove: Bool = false) throws {
    var index: UnsafePointer<UInt8> = path.utf8Start
    let end = path.utf8Start.advanced(by: path.utf8CodeUnitCount)
    var currentPoint = CGPoint()
    while index < end {
        let c = index.pointee
        index = index.successor()

        if c == 77 { // M
            let x = try readSvgValue(&index, end: end, separator: 44)
            let y = try readSvgValue(&index, end: end, separator: 32)

            // print("Move to \(x), \(y)")
            currentPoint = CGPoint(x: x, y: y)
            context.move(to: currentPoint)
        } else if c == 76 { // L
            let x = try readSvgValue(&index, end: end, separator: 44)
            let y = try readSvgValue(&index, end: end, separator: 32)

            // print("Line to \(x), \(y)")
            currentPoint = CGPoint(x: x, y: y)
            context.addLine(to: currentPoint)

            if strokeOnMove {
                context.strokePath()
                context.move(to: currentPoint)
            }
        } else if c == 72 { // H
            let x = try readSvgValue(&index, end: end, separator: 32)

            // print("Move to \(x), \(y)")
            currentPoint = CGPoint(x: x, y: currentPoint.y)
            context.addLine(to: currentPoint)
        } else if c == 86 { // V
            let y = try readSvgValue(&index, end: end, separator: 32)

            // print("Move to \(x), \(y)")
            currentPoint = CGPoint(x: currentPoint.x, y: y)
            context.addLine(to: currentPoint)
        } else if c == 67 { // C
            let x1 = try readSvgValue(&index, end: end, separator: 44)
            let y1 = try readSvgValue(&index, end: end, separator: 32)
            let x2 = try readSvgValue(&index, end: end, separator: 44)
            let y2 = try readSvgValue(&index, end: end, separator: 32)
            let x = try readSvgValue(&index, end: end, separator: 44)
            let y = try readSvgValue(&index, end: end, separator: 32)

            currentPoint = CGPoint(x: x, y: y)
            context.addCurve(to: currentPoint, control1: CGPoint(x: x1, y: y1), control2: CGPoint(x: x2, y: y2))

            // print("Line to \(x), \(y)")
            if strokeOnMove {
                context.strokePath()
                context.move(to: currentPoint)
            }
        } else if c == 90 { // Z
            if index != end, index.pointee != 32 {
                throw ParsingError.Generic
            }

            // CGContextClosePath(context)
            context.fillPath()
            // CGContextBeginPath(context)
            // print("Close")
        } else if c == 83 { // S
            if index != end, index.pointee != 32 {
                throw ParsingError.Generic
            }

            // CGContextClosePath(context)
            context.strokePath()
            // CGContextBeginPath(context)
            // print("Close")
        } else if c == 32 { // space
            continue
        } else {
            throw ParsingError.Generic
        }
    }
}
