import AppKit
import SwiftUI

/// Renders the shared shipping UI with the real display controller. No mock state.
@main
@MainActor
struct StoreScreenshots {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        app.appearance = NSAppearance(named: .aqua)
        let locale = Bundle.main.preferredLocalizations.first == "tr" ? "tr" : "en"
        let output = URL(fileURLWithPath: CommandLine.arguments[1])
        try! FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        let boost = BoostController()
        guard boost.isSupported else { fatalError("A compatible built-in display is required") }
        let host = NSHostingView(rootView: BrighterPanel(boost: boost).environment(\.locale, Locale(identifier: locale)).environment(\.colorScheme, .light))
        let panel = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 340), styleMask: [.borderless], backing: .buffered, defer: false)
        panel.backgroundColor = NSColor.windowBackgroundColor
        panel.appearance = NSAppearance(named: .aqua)
        panel.contentView = host
        panel.center()
        panel.orderFrontRegardless()

        let titles = locale == "tr"
            ? ["HDR parlaklığı.\nTek anahtar.", "Ekranınıza göre\nayarlayın.", "Yerel çalışır.\nGizliliğinizi korur."]
            : ["HDR brightness.\nOne switch.", "Dial in\nyour display.", "Local by design.\nPrivate by default."]
        let subtitles = locale == "tr"
            ? ["Menü çubuğunuzdan açın ve kapatın.", "HDR artışını kaydırıcıyla kontrol edin.", "Hesap, reklam veya takip sistemi yok."]
            : ["Enable and disable from your menu bar.", "Control HDR boost with a simple slider.", "No accounts, ads or tracking."]

        var index = 0
        func next() {
            guard index < 3 else { boost.setActive(false); app.terminate(nil); return }
            boost.setFactor(index == 1 ? 3 : 2)
            boost.setActive(index < 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                host.layoutSubtreeIfNeeded()
                panel.setContentSize(host.fittingSize)
                host.layoutSubtreeIfNeeded()
                guard let capture = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { fatalError("UI capture unavailable") }
                host.cacheDisplay(in: host.bounds, to: capture)
                let panelImage = NSImage(size: host.bounds.size)
                panelImage.addRepresentation(capture)
                let canvas = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1440, pixelsHigh: 900, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
                NSGraphicsContext.saveGraphicsState()
                NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: canvas)
                NSGradient(starting: NSColor(red: 0.07, green: 0.11, blue: 0.22, alpha: 1), ending: NSColor(red: 0.17, green: 0.24, blue: 0.39, alpha: 1))!.draw(in: NSRect(x: 0, y: 0, width: 1440, height: 900), angle: 25)
                let gold = NSColor(red: 1, green: 0.79, blue: 0.35, alpha: 1)
                func text(_ value: String, _ rect: NSRect, _ size: CGFloat, _ color: NSColor, _ weight: NSFont.Weight = .regular) {
                    (value as NSString).draw(in: rect, withAttributes: [.font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: color])
                }
                NSImage(contentsOfFile: Bundle.main.resourceURL!.appendingPathComponent("Brighter.icns").path)!.draw(in: NSRect(x: 85, y: 700, width: 92, height: 92))
                text("Brighter", NSRect(x: 190, y: 713, width: 450, height: 58), 42, .white, .semibold)
                text(titles[index], NSRect(x: 95, y: 410, width: 760, height: 240), 64, .white, .bold)
                text(subtitles[index], NSRect(x: 100, y: 340, width: 730, height: 90), 25, .white.withAlphaComponent(0.82))
                text(locale == "tr" ? "UYUMLU YERLEŞİK XDR EKRAN GEREKTİRİR" : "REQUIRES A COMPATIBLE BUILT-IN XDR DISPLAY", NSRect(x: 100, y: 166, width: 750, height: 65), 17, gold, .semibold)
                text(locale == "tr" ? "macOS 14+ · Apple silicon\nGörüntü fiziksel parlaklık artışını temsil etmez." : "macOS 14+ · Apple silicon\nScreenshot does not represent physical brightness output.", NSRect(x: 100, y: 87, width: 760, height: 76), 18, .white.withAlphaComponent(0.65))
                let destination = NSRect(x: 910, y: 450 - panelImage.size.height * 0.7, width: 420, height: panelImage.size.height * 1.4)
                let shadow = NSShadow(); shadow.shadowColor = .black.withAlphaComponent(0.45); shadow.shadowBlurRadius = 35; shadow.shadowOffset = NSSize(width: 0, height: -18); shadow.set()
                NSColor.white.setFill()
                NSBezierPath(roundedRect: destination, xRadius: 22, yRadius: 22).fill()
                NSShadow().set()
                NSBezierPath(roundedRect: destination, xRadius: 22, yRadius: 22).addClip()
                panelImage.draw(in: destination)
                NSGraphicsContext.restoreGraphicsState()
                try! canvas.representation(using: .jpeg, properties: [.compressionFactor: 1])!.write(to: output.appendingPathComponent("\(index + 1)-\(locale).jpg"))
                print("Captured \(index + 1)-\(locale).jpg, active=\(boost.isActive), factor=\(boost.factor)")
                index += 1
                next()
            }
        }
        next()
        app.run()
    }
}
