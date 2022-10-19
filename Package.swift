// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Danger",
    platforms: [.iOS("15"), .macOS("11")],
    products: [
        .library(name: "DangerDeps", type: .dynamic, targets: ["DangerDependencies"]), // dev
    ],
    dependencies: [
        .package(name: "Danger", url: "https://github.com/danger/swift.git", from: "3.14.2"), // dev
        .package(name: "DangerSwiftCoverage", url: "https://github.com/f-meloni/danger-swift-coverage", from: "1.2.1") // dev
    ],
    targets: [
        .target(name: "DangerDependencies", dependencies: ["Danger", "DangerSwiftCoverage"]), // dev
    ]
)
