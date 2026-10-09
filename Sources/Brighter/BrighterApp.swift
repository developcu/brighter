import AppKit
import SwiftUI

@main
struct BrighterApp: App {
    @State private var boost = BoostController()

    var body: some Scene {
        MenuBarExtra {
            BrighterPanel(boost: boost)
        } label: {
            Image(systemName: boost.isActive ? "sun.max.fill" : "sun.max")
                .accessibilityLabel("Brighter")
        }
        .menuBarExtraStyle(.window)
    }
}
