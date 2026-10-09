// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Brighter",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "BrighterCore", targets: ["BrighterCore"]),
        .executable(name: "Brighter", targets: ["Brighter"]),
    ],
    targets: [
        .target(name: "BrighterCore"),
        .executableTarget(name: "Brighter", dependencies: ["BrighterCore"]),
        .testTarget(name: "BrighterCoreTests", dependencies: ["BrighterCore"]),
    ]
)
