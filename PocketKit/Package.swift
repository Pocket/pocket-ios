// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketKit",
    defaultLocalization: "en",
    platforms: [.iOS("16"), .macOS("11")],
    products: [
        .library(name: "PocketKit", targets: ["PocketKit"]),
        .library(name: "PocketGraphTestMocks", targets: ["PocketGraphTestMocks"]),
        .library(name: "SaveToPocketKit", targets: ["SaveToPocketKit"]),
        .library(name: "SharedPocketKit", targets: ["SharedPocketKit"]),
        .library(name: "Textile", targets: ["Textile"]),
        .library(name: "Sync", targets: ["Sync"]),
        .library(name: "Analytics", targets: ["Analytics"]),
        .library(name: "Localization", targets: ["Localization"]),
        .library(name: "PKTListen", targets: ["PKTListen"])
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", exact: "1.1.3"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "7.6.2"),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", exact: "8.5.0"),
        .package(url: "https://github.com/snowplow/snowplow-objc-tracker", exact: "5.0.0"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", exact: "4.1.3"),
        .package(url: "https://github.com/johnxnguyen/Down", exact: "0.11.0"),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit.git", exact: "1.4.0"),
        .package(url: "https://github.com/braze-inc/braze-swift-sdk.git", exact: "5.14.0"),
        .package(url: "https://github.com/adjust/ios_sdk", exact: "4.33.4"),
        .package(url: "https://github.com/RNCryptor/RNCryptor.git", exact: "5.1.0"),
    ],
    targets: [
        .binaryTarget(name: "PKTListen", path: "./Frameworks/PKTListen.xcframework"),

        .target(
            name: "PocketKit",
            dependencies: [
                "Sync",
                "Textile",
                "Analytics",
                "SharedPocketKit",
                "Localization",
                "PKTListen",
                .product(name: "YouTubePlayerKit", package: "YouTubePlayerKit"),
                .product(name: "BrazeKit", package: "braze-swift-sdk"),
                .product(name: "BrazeUI", package: "braze-swift-sdk"),
                .product(name: "Adjust", package: "ios_sdk")
            ],
            linkerSettings: [.unsafeFlags(["-ObjC"])] // Needed to load categories in PKTListen
        ),
        .testTarget(
            name: "PocketKitTests",
            dependencies: ["PocketKit", "SharedPocketKit"]
        ),
        .target(
            name: "SaveToPocketKit",
            dependencies: [
                "SharedPocketKit",
                "Textile",
                "Sync",
                "Analytics",
                .product(name: "Adjust", package: "ios_sdk"),
                .product(name: "BrazeKit", package: "braze-swift-sdk")
            ]
        ),
        .testTarget(
            name: "SaveToPocketKitTests",
            dependencies: ["SaveToPocketKit"],
            resources: [.copy("Fixtures")]
        ),

        .target(
            name: "SharedPocketKit",
            dependencies: [
                "Textile",
                "Localization",
                "RNCryptor",
                .product(name: "Sentry", package: "sentry-cocoa")
            ]
        ),
        .testTarget(
            name: "SharedPocketKitTests",
            dependencies: ["SharedPocketKit"]
        ),

        .target(
            name: "Textile",
            dependencies: [
                "Localization",
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "Down", package: "Down"),
                .product(name: "Lottie", package: "lottie-ios"),
            ],
            resources: [
                .copy("Assets"),
                .copy("Style/Typography/Fonts"),
                .process("Style/Colors/Colors.xcassets"),
                .process("Style/Images/Images.xcassets"),
            ]
        ),

        .target(
            name: "Sync",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
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
            name: "PocketGraphTestMocks",
            dependencies: [
                .product(name: "ApolloAPI", package: "apollo-ios"),
                .product(name: "ApolloTestSupport", package: "apollo-ios"),
                "PocketGraph"
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

        .target(name: "Localization"),
    ]
)
