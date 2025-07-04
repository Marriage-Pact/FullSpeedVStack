// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FullSpeedVStack",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "FullSpeedVStack",
            targets: ["FullSpeedVStack"]),
    ],
    targets: [
        .target(
            name: "FullSpeedVStack"),
    ]
)
