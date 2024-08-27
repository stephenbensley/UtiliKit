// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UtiliKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "UtiliKit",
            targets: ["CheckersKit", "UtiliKit"]),
    ],
    targets: [
        .target(
            name: "CheckersKit"),
        .target(
            name: "UtiliKit"),
        .testTarget(
            name: "UtiliKitTests",
            dependencies: ["UtiliKit"]),
    ]
)
