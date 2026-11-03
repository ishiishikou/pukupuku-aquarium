// Create an original temporary 1024x1024 AppIcon at build time.
// Packaging placeholder only, not approved App Store branding.
// Usage (from repository root): swift ios/scripts/GeneratePrototypeIcon.swift
import AppKit
import Foundation

let side = 1024
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: side,
    pixelsHigh: side,
    bitsPerSample: 8,
    samplesPerPixel: 3,
    hasAlpha: false,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 24
), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fatalError("Unable to allocate prototype AppIcon bitmap")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
let bounds = NSRect(x: 0, y: 0, width: side, height: side)
NSColor(calibratedRed: 0.10, green: 0.68, blue: 0.79, alpha: 1).setFill()
NSBezierPath(rect: bounds).fill()

func filledBubble(_ x: CGFloat, _ y: CGFloat, _ diameter: CGFloat, _ opacity: CGFloat) {
    let ellipse = NSBezierPath(ovalIn: NSRect(x: x, y: y, width: diameter, height: diameter))
    NSColor(calibratedRed: 0.87, green: 1, blue: 1, alpha: opacity).setFill()
    ellipse.fill()
}
filledBubble(230, 150, 580, 0.45)
filledBubble(330, 370, 310, 0.80)
filledBubble(640, 650, 130, 0.65)
filledBubble(200, 690, 100, 0.73)
filledBubble(700, 300, 70, 0.62)

NSGraphicsContext.current?.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

let base = "ios/Sources/Assets.xcassets/AppIcon.appiconset"
try FileManager.default.createDirectory(atPath: base, withIntermediateDirectories: true)
guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Unable to produce AppIcon PNG")
}
try png.write(to: URL(fileURLWithPath: base + "/AppIcon-1024.png"))
let manifest = """
{
  "images": [
    { "filename": "AppIcon-1024.png", "idiom": "universal", "platform": "ios", "size": "1024x1024" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
"""
try manifest.write(toFile: base + "/Contents.json", atomically: true, encoding: .utf8)
print("Created temporary iOS AppIcon (1024x1024)")
