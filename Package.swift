// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUpdateKit",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftUpdateKit",
            targets: ["SwiftUpdateKit"]),
    ],
    targets: [
        .target(
            name: "SwiftUpdateKit"),
        .testTarget(
            name: "SwiftUpdateKitTests",
            dependencies: ["SwiftUpdateKit"]
        ),
    ]
)
