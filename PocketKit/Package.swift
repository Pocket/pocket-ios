// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PackageDescription

let package = Package(
    name: "PocketKit",
    defaultLocalization: "en",
    platforms: [.iOS("17"), .macOS("14")],
    products: [
        .library(name: "PocketKit", targets: ["PocketKit"]),
        .library(name: "PocketGraphTestMocks", targets: ["PocketGraphTestMocks"]),
        .library(name: "SaveToPocketKit", targets: ["SaveToPocketKit"]),
        .library(name: "SharedPocketKit", targets: ["SharedPocketKit"]),
        .library(name: "Textile", targets: ["Textile"]),
        .library(name: "Sync", targets: ["Sync"]),
        .library(name: "Database", targets: ["Database"]),
        .library(name: "Analytics", targets: ["Analytics"]),
        .library(name: "Localization", targets: ["Localization"]),
        .library(name: "PKTListen", targets: ["PKTListen"]),
        .library(name: "PocketStickerKit", targets: ["PocketStickerKit"]),
        .library(name: "DiffMatchPatch", targets: ["DiffMatchPatch"])
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.12.2"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.11.0"),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", from: "8.22.4"),
        .package(url: "https://github.com/snowplow/snowplow-objc-tracker", from: "6.0.3"),
        .package(url: "https://github.com/ccgus/fmdb", from: "2.7.11"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.4.3"),
        .package(url: "https://github.com/johnxnguyen/Down", from: "0.11.0"),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit.git", from: "1.8.0"),
        .package(url: "https://github.com/braze-inc/braze-swift-sdk.git", from: "9.3.0"),
        .package(url: "https://github.com/adjust/ios_sdk", from: "4.38.3"),
        .package(url: "https://github.com/RNCryptor/RNCryptor.git", from: "5.1.0"),
        .package(url: "https://github.com/vadymmarkov/Fakery", from: "5.1.0")
    ],
    targets: [
        .binaryTarget(
            name: "PKTListen",
            url: "https://github.com/Pocket/pocket-ios/releases/download/release%2Fv8.7.0-beta.1/PKTListen.xcframework.zip",
            checksum: "4d09c80cd6b0f9916f38554155d53c47c3f40ba95f730a9f8fe239594dea4fab"
        ),
        .binaryTarget(
            name: "DiffMatchPatch",
            path: "Frameworks/DiffMatchPatch.xcframework"
        ),
        .target(
            name: "PocketStickerKit",
            dependencies: [
                "Analytics",
                "SharedPocketKit",
                "Textile",
                "Sync",
                .product(name: "Adjust", package: "ios_sdk"),
                .product(name: "BrazeKit", package: "braze-swift-sdk")
            ],
            resources: [
                .copy("Stickers")
            ]
        ),
        .target(name: "Database", dependencies: [
            .product(name: "Fakery", package: "Fakery"),
        ]),
        .target(
            name: "PocketKit",
            dependencies: [
                "Sync",
                "Textile",
                "Analytics",
                "SharedPocketKit",
                "Database",
                "Localization",
                "PKTListen",
                "DiffMatchPatch",
                .product(name: "YouTubePlayerKit", package: "YouTubePlayerKit"),
                .product(name: "BrazeKit", package: "braze-swift-sdk"),
                .product(name: "BrazeUI", package: "braze-swift-sdk"),
                .product(name: "Adjust", package: "ios_sdk"),
                // Used by listen, ideally we put this there, but there were some c99 compilker issues, this used to be included by snowplow but is not anymore
                .product(name: "FMDB", package: "fmdb")
            ],
            swiftSettings: [
                    .enableExperimentalFeature("StrictConcurrency=complete")
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
                .product(name: "BrazeKit", package: "braze-swift-sdk"),
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
