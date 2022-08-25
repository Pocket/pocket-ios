// swift-tools-version:5.6
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
        .executable(name: "ApolloCodegen", targets: ["ApolloCodegen"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", .upToNextMajor(from: "0.51.2")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", branch:("fix/xcode-13")),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/snowplow/snowplow-objc-tracker", .upToNextMinor(from: "2.2.0")),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "3.2.1"),
        .package(url: "https://github.com/johnxnguyen/Down", .upToNextMinor(from: "0.11.0")),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit.git", .upToNextMinor(from: "1.1.5"))
    ],
    targets: [
        .target(
            name: "PocketKit",
            dependencies: [
                "Sync",
                "Textile",
                "Analytics",
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "YouTubePlayerKit", package: "YouTubePlayerKit"),
                "SharedPocketKit"
            ],
            resources: [.copy("Assets")]
        ),
        .testTarget(
            name: "PocketKitTests",
            dependencies: [
                "PocketKit",
                "SharedPocketKit"
            ],
            resources: [.copy("Fixtures")]
        ),

        .target(
            name: "SaveToPocketKit",
            dependencies: [
                "SharedPocketKit",
                "Textile",
                "Sync"
            ]
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
                .product(name: "Sentry", package: "sentry-cocoa")
            ],
            exclude: [
                "list.graphql",
                "marticle.graphql",
                "archive.graphql",
                "schema.graphqls",
                "introspection_response.json"
            ],
            resources: [.process("PocketModel.xcdatamodeld")]
        ),
        .testTarget(
            name: "SyncTests",
            dependencies: ["Sync"],
            resources: [.copy("Fixtures")]
        ),
        
        .target(
            name: "Analytics",
            dependencies: [.product(name: "SnowplowTracker", package: "snowplow-objc-tracker"),]
        ),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: ["Analytics"]
        ),

        .executableTarget(
            name: "ApolloCodegen",
            dependencies: [
                .product(name: "ApolloCodegenLib", package: "apollo-ios"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
