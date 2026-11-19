// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
    name: "GruffixToasts",
    platforms: [.iOS("17.0"), .macOS("14.0"), .tvOS("17.0"), .watchOS("10.0")],
    products: [
        .library(name: "GruffixToasts", targets: ["GruffixToasts"]),
    ],
    targets: [
        .target(
            name: "GruffixToasts",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "GruffixToastsTests",
            dependencies: ["GruffixToasts"],
            swiftSettings: swiftSettings
        ),
    ]
)
