// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


struct LaunchArguments {
    let clearKeychain: Bool
    let clearUserDefaults: Bool
    let clearFirstLaunch: Bool
    let clearCoreData: Bool
    let clearImageCache: Bool
    let disableSentry: Bool
    let disableSnowplow: Bool
    
    init(
        clearKeychain: Bool,
        clearUserDefaults: Bool,
        clearFirstLaunch: Bool,
        clearCoreData: Bool,
        clearImageCache: Bool,
        disableSentry: Bool,
        disableSnowplow: Bool
    ) {
        self.clearKeychain = clearKeychain
        self.clearUserDefaults = clearUserDefaults
        self.clearFirstLaunch = clearFirstLaunch
        self.clearCoreData = clearCoreData
        self.clearImageCache = clearImageCache
        self.disableSentry = disableSentry
        self.disableSnowplow = disableSnowplow
    }
    
    func toArray() -> [String] {
        var args: [String] = []
        if clearKeychain {
            args.append("clearKeychain")
        }
        if clearUserDefaults {
            args.append("clearUserDefaults")
        }
        if clearFirstLaunch {
            args.append("clearFirstLaunch")
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
        return args
    }

    func with(clearKeychain: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearFirstLaunch: clearFirstLaunch, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow)
    }

    func with(clearUserDefaults: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearFirstLaunch: clearFirstLaunch, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow)
    }

    func with(clearFirstLaunch: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearFirstLaunch: clearFirstLaunch, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow)
    }

    func with(clearCoreData: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearFirstLaunch: clearFirstLaunch, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow)
    }

    func with(clearImageCache: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearFirstLaunch: clearFirstLaunch, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow)
    }

    func with(disableSentry: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearFirstLaunch: clearFirstLaunch, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow)
    }

    func with(disableSnowplow: Bool) -> LaunchArguments {
        LaunchArguments(clearKeychain: clearKeychain, clearUserDefaults: clearUserDefaults, clearFirstLaunch: clearFirstLaunch, clearCoreData: clearCoreData, clearImageCache: clearImageCache, disableSentry: disableSentry, disableSnowplow: disableSnowplow)
    }
}

extension LaunchArguments {
    static let preserve = LaunchArguments(
        clearKeychain: false,
        clearUserDefaults: false,
        clearFirstLaunch: false,
        clearCoreData: false,
        clearImageCache: false,
        disableSentry: true,
        disableSnowplow: true
    )

    static let firstLaunch = LaunchArguments(
        clearKeychain: true,
        clearUserDefaults: true,
        clearFirstLaunch: true,
        clearCoreData: true,
        clearImageCache: true,
        disableSentry: true,
        disableSnowplow: true
    )

    static let bypassSignIn = LaunchArguments(
        clearKeychain: true,
        clearUserDefaults: true,
        clearFirstLaunch: false,
        clearCoreData: true,
        clearImageCache: true,
        disableSentry: true,
        disableSnowplow: true
    )
}
