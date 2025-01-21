// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mobile",
    platforms: [
        .iOS(.v13),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Mobile",
            targets: ["Mobile"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "MobileCore",
            path: "ios/binaries/MobileCore.xcframework"
        ),
        .target(
            name: "Mobile",
            dependencies: [.target(name: "MobileCore")],
            path: "ios/src/Mobile"
        )
    ]
)

