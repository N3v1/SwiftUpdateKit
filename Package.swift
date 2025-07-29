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
            targets: ["SwiftUpdateKit"]
        ),
        .executable(
            name: "swift-update-gen",
            targets: ["swift-update-gen"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
    ],
    targets: [
        .target(
            name: "SwiftUpdateKit",
            path: "Sources/SwiftUpdateKit"
        ),
        .executableTarget(
            name: "swift-update-gen", 
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/swift-update-gen"
        ),
        .testTarget(
            name: "SwiftUpdateKitTests",
            dependencies: ["SwiftUpdateKit"]
        ),
    ]
)
