// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketKit",
    platforms: [.iOS("15"), .macOS("11")],
    products: [
        .library(name: "PocketKit", targets: ["PocketKit"]),
        .library(name: "Textile", targets: ["Textile"]),
        .library(name: "Sync", targets: ["Sync"]),
        .library(name: "Analytics", targets: ["Analytics"]),
        .executable(name: "ApolloCodegen", targets: ["ApolloCodegen"]),
    ],
    dependencies: [
        .package(name: "Apollo", url: "https://github.com/apollographql/apollo-ios.git", .upToNextMajor(from: "0.51.2")),
        .package(name: "Kingfisher", url: "https://github.com/onevcat/Kingfisher.git", .branch("fix/xcode-13")),
        .package(name: "Sentry", url: "https://github.com/getsentry/sentry-cocoa.git", .upToNextMajor(from: "7.0.0")),
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.0")),
        .package(name: "SnowplowTracker", url: "https://github.com/snowplow/snowplow-objc-tracker", .upToNextMinor(from: "2.2.0")),
        .package(name: "Lottie", url: "https://github.com/airbnb/lottie-ios.git", from: "3.2.1"),
        .package(name: "Down", url: "https://github.com/johnxnguyen/Down", .upToNextMinor(from: "0.11.0")),
        .package(name: "YouTubePlayerKit", url: "https://github.com/SvenTiigi/YouTubePlayerKit.git", .upToNextMinor(from: "1.1.5"))
    ],
    targets: [
        .target(
            name: "PocketKit",
            dependencies: ["Sync", "Textile", "Analytics", "Lottie", "YouTubePlayerKit"],
            resources: [.copy("Assets")]
        ),
        .testTarget(
            name: "PocketKitTests",
            dependencies: ["PocketKit"],
            resources: [.copy("Fixtures")]
        ),

        .target(
            name: "Textile",
            dependencies: ["Kingfisher", "Down"],
            resources: [
                .copy("Style/Typography/Fonts"),
                .process("Style/Colors/Colors.xcassets"),
                .process("Style/Icons/Icons.xcassets"),
            ]
        ),

        .target(
            name: "Sync",
            dependencies: ["Apollo", "Sentry"],
            exclude: ["list.graphql", "marticle.graphql", "schema.json"],
            resources: [.process("PocketModel.xcdatamodeld")]
        ),
        .testTarget(
            name: "SyncTests",
            dependencies: ["Sync"],
            resources: [.copy("Fixtures")]
        ),
        
        .target(
            name: "Analytics",
            dependencies: ["SnowplowTracker"]
        ),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: ["Analytics"]
        ),

        .executableTarget(
            name: "ApolloCodegen",
            dependencies: [
                .product(name: "ApolloCodegenLib", package: "Apollo"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
