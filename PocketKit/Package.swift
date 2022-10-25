// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketKit",
    platforms: [.iOS("15"), .macOS("11")],
    products: [
        .library(name: "PocketKit", targets: ["PocketKit"]),
        .library(name: "SaveToPocketKit", targets: ["SaveToPocketKit"]),
        .library(name: "SharedPocketKit", targets: ["SharedPocketKit"]),
        .library(name: "Textile", targets: ["Textile"]),
        .library(name: "Sync", targets: ["Sync"]),
        .library(name: "Analytics", targets: ["Analytics"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", .upToNextMajor(from: "1.0.2")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.3.2")),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", .upToNextMajor(from: "7.25.0")),
        .package(url: "https://github.com/snowplow/snowplow-objc-tracker", .upToNextMajor(from: "3.2.0")),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "3.4.3"),
        .package(url: "https://github.com/johnxnguyen/Down", .upToNextMinor(from: "0.11.0")),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit.git", .upToNextMinor(from: "1.1.5")),
        .package(url: "https://github.com/braze-inc/braze-swift-sdk.git", .upToNextMajor(from: "5.5.0"))
    ],
    targets: [
        .target(
            name: "PocketKit",
            dependencies: [
                "Sync",
                "Textile",
                "Analytics",
                "SharedPocketKit",
                .product(name: "YouTubePlayerKit", package: "YouTubePlayerKit"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "BrazeKit", package: "braze-swift-sdk"),
                .product(name: "BrazeUI", package: "braze-swift-sdk")
            ],
            resources: [.copy("Assets")]
        ),
        .testTarget(
            name: "PocketKitTests",
            dependencies: ["PocketKit", "SharedPocketKit"]
        ),

        .target(
            name: "SaveToPocketKit",
            dependencies: ["SharedPocketKit", "Textile", "Sync"]
        ),
        .testTarget(
            name: "SaveToPocketKitTests",
            dependencies: ["SaveToPocketKit"],
            resources: [.copy("Fixtures")]
        ),

        .target(
            name: "SharedPocketKit"
        ),
        .testTarget(
            name: "SharedPocketKitTests",
            dependencies: ["SharedPocketKit"]
        ),

        .target(
            name: "Textile",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "Down", package: "Down")
            ],
            resources: [
                .copy("Style/Typography/Fonts"),
                .process("Style/Colors/Colors.xcassets"),
                .process("Style/Images/Images.xcassets"),
            ]
        ),

        .target(
            name: "Sync",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "Sentry", package: "sentry-cocoa"),
                "PocketGraph"
            ],
            resources: [.process("PocketModel.xcdatamodeld")]
        ),
        .testTarget(
            name: "SyncTests",
            dependencies: ["Sync"],
            resources: [.copy("Fixtures")]
        ),

        .target(
            name: "PocketGraph",
            dependencies: [
                .product(name: "ApolloAPI", package: "apollo-ios"),
            ],
            exclude: [
                "user-defined-operations",
                "schema.graphqls"
            ]
        ),

        .target(
            name: "Analytics",
            dependencies: [
                .product(name: "SnowplowTracker", package: "snowplow-objc-tracker")
            ]
        ),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: ["Analytics"]
        ),
    ]
)
