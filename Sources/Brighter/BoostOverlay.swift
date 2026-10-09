import AppKit
import MetalKit

@MainActor
final class BoostOverlay {
    private let window: NSWindow
    private let view: MTKView
    private let renderer: ClearRenderer
    private let displayID: CGDirectDisplayID
    private let screenFrame: NSRect

    init?(screen: NSScreen, device: MTLDevice, factor: Double) {
        guard let renderer = ClearRenderer(device: device),
              let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
        else { return nil }
        self.renderer = renderer
        displayID = CGDirectDisplayID(screenNumber.uint32Value)
        screenFrame = screen.frame

        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false,
            screen: screen
        )
        window.level = .screenSaver
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.hidesOnDeactivate = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]

        let view = MTKView(frame: NSRect(origin: .zero, size: screen.frame.size), device: device)
        view.colorPixelFormat = .rgba16Float
        view.colorspace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)
        view.clearColor = MTLClearColor(red: factor, green: factor, blue: factor, alpha: 1)
        view.isPaused = false
        view.enableSetNeedsDisplay = false
        view.preferredFramesPerSecond = 30
        view.delegate = renderer
        view.wantsLayer = true
        window.contentView = view

        guard let metalLayer = view.layer as? CAMetalLayer else { return nil }
        metalLayer.isOpaque = false
        metalLayer.wantsExtendedDynamicRangeContent = true
        // The compositor preset works across windows; Core Image filters render
        // inside this app and did not preserve desktop brightness in device testing.
        // The preset name is undocumented and is disclosed in App Review notes.
        metalLayer.compositingFilter = "multiply"

        self.window = window
        self.view = view
        window.orderFrontRegardless()
        view.draw()
    }

    func setFactor(_ factor: Double) {
        view.clearColor = MTLClearColor(red: factor, green: factor, blue: factor, alpha: 1)
        view.draw()
    }

    var submittedFrameCount: UInt64 { renderer.submittedFrameCount }

    func matches(screen: NSScreen) -> Bool {
        guard let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
            return false
        }
        return displayID == CGDirectDisplayID(screenNumber.uint32Value) && screenFrame == screen.frame
    }

    deinit {
        MainActor.assumeIsolated { window.orderOut(nil) }
    }
}

@MainActor
private final class ClearRenderer: NSObject, MTKViewDelegate {
    private let queue: MTLCommandQueue
    private(set) var submittedFrameCount: UInt64 = 0

    init?(device: MTLDevice) {
        guard let queue = device.makeCommandQueue() else { return nil }
        self.queue = queue
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let pass = view.currentRenderPassDescriptor,
              let drawable = view.currentDrawable,
              let buffer = queue.makeCommandBuffer(),
              let encoder = buffer.makeRenderCommandEncoder(descriptor: pass) else { return }
        encoder.endEncoding()
        buffer.present(drawable)
        buffer.commit()
        submittedFrameCount += 1
    }
}
