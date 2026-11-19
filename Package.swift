// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GruffixToasts",
    platforms: [.iOS("27.0")],
    products: [
        .library(name: "GruffixToasts", targets: ["GruffixToasts"]),
    ],
    targets: [
        .target(
            name: "GruffixToasts",
            swiftSettings: [
                .defaultIsolation(MainActor.self),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ]
        ),
    ]
)
