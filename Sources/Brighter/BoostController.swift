import AppKit
import BrighterCore
import CoreGraphics
import Metal
import Observation

@Observable
@MainActor
final class BoostController {
    private(set) var isActive = false
    private(set) var wantsBoost = false
    private(set) var isSupported = false
    private(set) var factor = 2.0
    private(set) var maximumFactor = 1.0
    private(set) var status = String(localized: "Hazır")

    @ObservationIgnored private var overlay: BoostOverlay?
    @ObservationIgnored private var displayObserver: NSObjectProtocol?
    @ObservationIgnored private var wakeObserver: NSObjectProtocol?

    init() {
        refreshDisplay()
        displayObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.refreshDisplay() }
        }
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.refreshDisplay(forceRecreate: true) }
        }
    }

    func setActive(_ active: Bool) {
        wantsBoost = active
        guard active else {
            overlay = nil
            isActive = false
            status = String(localized: "Normal parlaklık")
            return
        }
        guard let screen = Self.builtInScreen() else {
            overlay = nil
            isActive = false
            status = String(localized: "Yerleşik ekran yeniden bağlanınca HDR artışı açılacak")
            return
        }
        guard let device = MTLCreateSystemDefaultDevice() else {
            overlay = nil
            isActive = false
            wantsBoost = false
            status = String(localized: "Metal aygıtı bulunamadı")
            return
        }
        let setting = BoostSetting(
            requested: factor,
            headroom: Double(screen.maximumPotentialExtendedDynamicRangeColorComponentValue)
        )
        guard setting.isSupported else {
            overlay = nil
            isActive = false
            wantsBoost = false
            status = String(localized: "Bu ekranda HDR artışı kullanılamıyor")
            return
        }
        guard let newOverlay = BoostOverlay(screen: screen, device: device, factor: setting.factor) else {
            overlay = nil
            isActive = false
            wantsBoost = false
            status = String(localized: "HDR katmanı başlatılamadı")
            return
        }
        overlay = newOverlay
        isActive = true
        status = String(localized: "HDR parlaklığı etkin")
    }

    func setFactor(_ requested: Double) {
        factor = BoostSetting(requested: requested, headroom: maximumFactor).factor
        overlay?.setFactor(factor)
    }

    private func refreshDisplay(forceRecreate: Bool = false) {
        guard let screen = Self.builtInScreen() else {
            overlay = nil
            isActive = false
            isSupported = false
            maximumFactor = 1
            status = wantsBoost
                ? String(localized: "Yerleşik ekran geri geldiğinde HDR artışı açılacak")
                : String(localized: "Yerleşik ekran bulunamadı")
            return
        }

        if wantsBoost, !forceRecreate, let overlay, overlay.matches(screen: screen) {
            let headroom = Double(screen.maximumPotentialExtendedDynamicRangeColorComponentValue)
            if headroom > 1 {
                let previousFactor = factor
                let setting = BoostSetting(requested: factor, headroom: headroom)
                maximumFactor = setting.maximumFactor
                factor = setting.factor
                if factor != previousFactor { overlay.setFactor(factor) }
            }
            isSupported = true
            isActive = true
            status = String(localized: "HDR parlaklığı etkin")
            return
        }

        overlay = nil
        isActive = false
        let setting = BoostSetting(
            requested: factor,
            headroom: Double(screen.maximumPotentialExtendedDynamicRangeColorComponentValue)
        )
        maximumFactor = setting.maximumFactor
        factor = setting.factor
        isSupported = setting.isSupported && MTLCreateSystemDefaultDevice() != nil
        status = isSupported ? String(localized: "Kapalı; açmak için anahtarı kullanın") : String(localized: "Bu ekranda HDR artışı kullanılamıyor")
        if wantsBoost && isSupported { setActive(true) }
    }

    private static func builtInScreen() -> NSScreen? {
        NSScreen.screens.first { screen in
            guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
                return false
            }
            return CGDisplayIsBuiltin(CGDirectDisplayID(number.uint32Value)) != 0
        }
    }
}
