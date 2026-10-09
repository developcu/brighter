import AppKit

let side = 1024
let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: side,
    pixelsHigh: side,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)!
let context = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context

let background = NSBezierPath(roundedRect: NSRect(x: 40, y: 40, width: 944, height: 944), xRadius: 225, yRadius: 225)
NSGradient(starting: NSColor(red: 0.18, green: 0.25, blue: 0.44, alpha: 1),
           ending: NSColor(red: 0.08, green: 0.12, blue: 0.25, alpha: 1))!
    .draw(in: background, angle: 125)

let center = NSPoint(x: 512, y: 512)
let rays = NSBezierPath()
rays.lineWidth = 42
rays.lineCapStyle = .round
for index in 0..<12 {
    let angle = Double(index) * .pi / 6
    rays.move(to: NSPoint(x: center.x + cos(angle) * 270, y: center.y + sin(angle) * 270))
    rays.line(to: NSPoint(x: center.x + cos(angle) * 360, y: center.y + sin(angle) * 360))
}
NSColor(red: 1, green: 0.78, blue: 0.34, alpha: 1).setStroke()
rays.stroke()

let sun = NSBezierPath(ovalIn: NSRect(x: 336, y: 336, width: 352, height: 352))
NSGradient(starting: NSColor(red: 1, green: 0.94, blue: 0.59, alpha: 1),
           ending: NSColor(red: 1, green: 0.56, blue: 0.19, alpha: 1))!
    .draw(in: sun, angle: 135)

context.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

let iconset = URL(fileURLWithPath: "Resources/Brighter.iconset")
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
let png = iconset.appendingPathComponent("icon_512x512@2x.png")
try rep.representation(using: .png, properties: [:])!.write(to: png)
