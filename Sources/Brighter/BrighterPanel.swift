import AppKit
import SwiftUI

struct BrighterPanel: View {
    let boost: BoostController

    var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(.yellow)
                    Text("Brighter")
                        .font(.headline)
                    Spacer()
                    Text(boost.isActive ? String(localized: "Açık") : String(localized: "Kapalı"))
                        .foregroundStyle(.secondary)
                }

                Toggle("HDR parlaklığı artır", isOn: Binding(
                    get: { boost.wantsBoost },
                    set: { boost.setActive($0) }
                ))
                .toggleStyle(.switch)
                .disabled(!boost.isSupported && !boost.wantsBoost)

                if boost.isSupported {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Artış")
                            Spacer()
                            Text(boost.factor.formatted(.number.precision(.fractionLength(1))) + "×")
                                .monospacedDigit()
                        }
                        Slider(value: Binding(
                            get: { boost.factor },
                            set: { boost.setFactor($0) }
                        ), in: 1...boost.maximumFactor)
                        .accessibilityLabel(Text("Artış"))
                        Text(String(localized: "Seçilebilir üst sınır: ") +
                             boost.maximumFactor.formatted(.number.precision(.fractionLength(1))) + "×")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Yerleşik ekranda kullanılabilir HDR parlaklık alanı bulunamadı.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Text(boost.status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Yerleşik XDR ekran gerektirir. Parlaklık, güç ve sıcaklık koşullarına göre değişir.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                HStack {
                    Link("Destek", destination: URL(string: "https://brighter-support.pages.dev/")!)
                    Spacer()
                    Link("Gizlilik", destination: URL(string: "https://brighter-support.pages.dev/privacy/")!)
                }
                .font(.caption)
                Button("Brighter'dan Çık") { NSApp.terminate(nil) }
            }
            .padding(16)
            .frame(width: 300)
    }
}
