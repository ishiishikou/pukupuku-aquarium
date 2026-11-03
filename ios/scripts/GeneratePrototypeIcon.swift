// Original temporary packaging artwork, not the final App Store icon.
// Run on macOS from repository root: swift ios/scripts/GeneratePrototypeIcon.swift
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let side = 1024
guard let context = CGContext(
    data: nil,
    width: side,
    height: side,
    bitsPerComponent: 8,
    bytesPerRow: side * 4,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else {
    fatalError("Could not create opaque RGB drawing context")
}
context.setFillColor(CGColor(red: 0.10, green: 0.68, blue: 0.79, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: side, height: side))

func bubble(_ x: CGFloat, _ y: CGFloat, _ diameter: CGFloat, _ opacity: CGFloat) {
    context.setFillColor(CGColor(red: 0.87, green: 1, blue: 1, alpha: opacity))
    context.fillEllipse(in: CGRect(x: x, y: y, width: diameter, height: diameter))
}
bubble(230, 150, 580, 0.45)
bubble(330, 370, 310, 0.80)
bubble(640, 650, 130, 0.65)
bubble(200, 690, 100, 0.73)
bubble(700, 300, 70, 0.62)

guard let image = context.makeImage() else { fatalError("No icon image") }
let base = "ios/Sources/Assets.xcassets/AppIcon.appiconset"
try FileManager.default.createDirectory(atPath: base, withIntermediateDirectories: true)
let data = NSMutableData()
guard let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("Unable to create PNG destination")
}
CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else { fatalError("PNG conversion failed") }
try (data as Data).write(to: URL(fileURLWithPath: base + "/AppIcon-1024.png"))
let manifest = """
{
  "images": [
    { "filename": "AppIcon-1024.png", "idiom": "universal", "platform": "ios", "size": "1024x1024" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
"""
try manifest.write(toFile: base + "/Contents.json", atomically: true, encoding: .utf8)
print("Generated temporary opaque 1024x1024 iOS AppIcon")
