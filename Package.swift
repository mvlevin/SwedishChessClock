// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwedishChessClock",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "SwedishChessClock",
            targets: ["SwedishChessClock"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "SwedishChessClock",
            dependencies: [],
            path: "SwedishChessClock"
        )
    ]
)
