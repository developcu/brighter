import AppKit
import BrighterCore
import CoreGraphics

@main
@MainActor
struct DisplayRefreshSmoke {
    private static func overlayWindowNumber() -> Int? {
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
        return windows.first { window in
            (window[kCGWindowOwnerPID as String] as? Int32) == getpid()
                && (window[kCGWindowLayer as String] as? Int) == Int(CGWindowLevelForKey(.screenSaverWindow))
        }?[kCGWindowNumber as String] as? Int
    }

    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let controller = BoostController()
        guard controller.isSupported else {
            fputs("FAIL: built-in EDR display unavailable\n", stderr)
            exit(1)
        }

        controller.setActive(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let originalWindow = overlayWindowNumber(), controller.isActive else {
                fputs("FAIL: HDR overlay did not open\n", stderr)
                exit(1)
            }

            for _ in 0..<5 {
                NotificationCenter.default.post(
                    name: NSApplication.didChangeScreenParametersNotification,
                    object: app
                )
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                guard controller.isActive,
                      overlayWindowNumber() == originalWindow
                else {
                    fputs("FAIL: HDR overlay was replaced by screen parameter notifications\n", stderr)
                    exit(1)
                }
                print("PASS: HDR overlay window \(originalWindow) stayed visible after display notifications")

                NSWorkspace.shared.notificationCenter.post(
                    name: NSWorkspace.didWakeNotification,
                    object: nil
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    guard controller.isActive,
                          let wakeWindow = overlayWindowNumber(),
                          wakeWindow != originalWindow
                    else {
                        fputs("FAIL: HDR overlay did not recover after wake notification\n", stderr)
                        exit(1)
                    }
                    print("PASS: HDR overlay recovered after wake notification")
                    controller.setActive(false)
                    app.terminate(nil)
                }
            }
        }
        app.run()
    }
}
