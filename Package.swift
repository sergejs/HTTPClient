// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTTPClient",
    platforms: [
        .macOS(.v12),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "HTTPClient",
            targets: ["HTTPClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/WeTransfer/Mocker.git", .upToNextMajor(from: "2.3.0")),
    ],
    targets: [
        .target(
            name: "HTTPClient",
            dependencies: []
        ),
        .testTarget(
            name: "HTTPClientTests",
            dependencies: ["HTTPClient", "Mocker"]
        ),
    ]
)
