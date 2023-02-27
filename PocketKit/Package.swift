// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketKit",
    defaultLocalization: "en",
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
        .package(url: "https://github.com/apollographql/apollo-ios.git", exact: "1.0.7"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "7.6.2"),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", exact: "8.2.0"),
        .package(url: "https://github.com/snowplow/snowplow-objc-tracker", exact: "4.1.0"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", exact: "3.5.0"),
        .package(url: "https://github.com/johnxnguyen/Down", exact: "0.11.0"),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit.git", exact: "1.1.12"),
        .package(url: "https://github.com/braze-inc/braze-swift-sdk.git", exact: "5.8.1")
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
            dependencies: ["SharedPocketKit", "Textile", "Sync", "Analytics"]
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
                "PocketGraph",
                "SharedPocketKit"
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
                .product(name: "SnowplowTracker", package: "snowplow-objc-tracker"),
                "Sync"
            ]
        ),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: ["Analytics"]
        ),
    ]
)
