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

        return args
    }

    func with(clearKeychain: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow, skipLegacyAccountMigration: skipLegacyAccountMigration)
    }

    func with(clearUserDefaults: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow, skipLegacyAccountMigration: skipLegacyAccountMigration)
    }

    func with(clearCoreData: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow, skipLegacyAccountMigration: skipLegacyAccountMigration)
    }

    func with(clearImageCache: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow, skipLegacyAccountMigration: skipLegacyAccountMigration)
    }

    func with(disableSentry: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow, skipLegacyAccountMigration: skipLegacyAccountMigration)
    }

    func with(disableSnowplow: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow, skipLegacyAccountMigration: skipLegacyAccountMigration)
    }
}

extension LaunchArguments {
    static let preserve = LaunchArguments(
        clearKeychain: false,
        clearUserDefaults: false,
        clearCoreData: false,
        clearImageCache: false,
        disableSentry: true,
        disableSnowplow: false,
        skipLegacyAccountMigration: false
    )

    static let bypassSignIn = LaunchArguments(
        clearKeychain: true,
        clearUserDefaults: true,
        clearCoreData: true,
        clearImageCache: true,
        disableSentry: true,
        disableSnowplow: false,
        skipLegacyAccountMigration: true
    )
}
