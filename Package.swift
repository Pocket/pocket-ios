// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PackageDescription

let package = Package(
    name: "Danger",
    platforms: [.iOS("16"), .macOS("13")],
    products: [
        .library(name: "DangerDeps", type: .dynamic, targets: ["DangerDependencies"]), // dev
    ],
    dependencies: [
        .package(url: "https://github.com/danger/swift.git", from: "3.18.1"), // dev
        .package(url: "https://github.com/f-meloni/danger-swift-coverage", from: "1.2.1") // dev
    ],
    targets: [
        .target(
            name: "DangerDependencies",
            dependencies: [
                .product(name: "Danger", package: "swift"),
                .product(name: "DangerSwiftCoverage", package: "danger-swift-coverage")
            ]
        ) // dev
    ]
)
