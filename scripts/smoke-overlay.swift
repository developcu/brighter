import AppKit
import CoreGraphics
import Metal
import MetalKit

@main
@MainActor
struct OverlaySmoke {
    static func main() {
        let application = NSApplication.shared
        application.setActivationPolicy(.accessory)

        guard let screen = NSScreen.screens.first(where: { screen in
            guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
                return false
            }
            return CGDisplayIsBuiltin(CGDirectDisplayID(number.uint32Value)) != 0
        }), let device = MTLCreateSystemDefaultDevice() else {
            fputs("FAIL: built-in display or Metal device unavailable\n", stderr)
            exit(1)
        }

        let before = screen.maximumExtendedDynamicRangeColorComponentValue
        guard let overlay = BoostOverlay(screen: screen, device: device, factor: 2) else {
            fputs("FAIL: overlay could not start\n", stderr)
            exit(1)
        }
        print("Overlay created. EDR before: \(before)")
        let view = Mirror(reflecting: overlay).children.first { $0.label == "view" }?.value as? MTKView
        let window = Mirror(reflecting: overlay).children.first { $0.label == "window" }?.value as? NSWindow
        print("Overlay at start: visible=\(window?.isVisible == true), layerOpaque=\(view?.layer?.isOpaque == true), filter=\(String(describing: view?.layer?.compositingFilter)), wantsEDR=\((view?.layer as? CAMetalLayer)?.wantsExtendedDynamicRangeContent == true)")
        fflush(stdout)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let current = NSScreen.screens.first(where: { $0.localizedName == screen.localizedName })?
                .maximumExtendedDynamicRangeColorComponentValue ?? 1
            print("EDR while active: \(current)")
            print("Frames submitted after 2 seconds: \(overlay.submittedFrameCount)")
            print("Overlay after 2 seconds: visible=\(window?.isVisible == true), layerOpaque=\(view?.layer?.isOpaque == true), filter=\(String(describing: view?.layer?.compositingFilter)), wantsEDR=\((view?.layer as? CAMetalLayer)?.wantsExtendedDynamicRangeContent == true)")
            fflush(stdout)
            guard overlay.submittedFrameCount >= 10 else {
                fputs("FAIL: overlay stopped rendering\n", stderr)
                exit(1)
            }
            application.terminate(nil)
        }
        application.run()
    }
}
