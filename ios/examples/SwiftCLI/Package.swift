// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftCLI",
    platforms: [
        .macOS(.v13)  
    ],
    dependencies: [
        .package(url: "git@github.com:mh-mobile/UniFFI-SPM-Sample.git", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "SwiftCLI",
            dependencies: [
              .product(name: "Mobile", package: "UniFFI-SPM-Sample")
            ] 
        )
    ]
)
