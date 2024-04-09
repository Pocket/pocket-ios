// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct LaunchArguments {
    let clearKeychain: Bool
    let clearUserDefaults: Bool
    let clearCoreData: Bool
    let clearImageCache: Bool
    let disableSentry: Bool
    let disableSnowplow: Bool
    let skipLegacyAccountMigration: Bool
    let hideAllTipsForTesting: Bool

    func toArray() -> [String] {
        var args: [String] = []
        if clearKeychain {
            args.append("clearKeychain")
        }
        if clearUserDefaults {
            args.append("clearUserDefaults")
        }
        if clearCoreData {
            args.append("clearCoreData")
        }
        if clearImageCache {
            args.append("clearImageCache")
        }
        if disableSentry {
            args.append("disableSentry")
        }
        if disableSnowplow {
            args.append("disableSnowplow")
        }
        if skipLegacyAccountMigration {
            args.append("skipLegacyAccountMigration")
        }
        if hideAllTipsForTesting {
            args.append("hideAllTipsForTesting")
        }

        return args
    }

    static let bypassSignIn = LaunchArguments(
        clearKeychain: true,
        clearUserDefaults: true,
        clearCoreData: true,
        clearImageCache: true,
        disableSentry: true,
        disableSnowplow: false,
        skipLegacyAccountMigration: true,
        hideAllTipsForTesting: true
    )
}
