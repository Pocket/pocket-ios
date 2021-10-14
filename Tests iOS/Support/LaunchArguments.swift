// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


struct LaunchArguments {
    let clearKeychain: Bool
    let clearCoreData: Bool
    let clearImageCache: Bool
    let disableSentry: Bool
    let disableSnowplow: Bool
    
    init(
        clearKeychain: Bool = true,
        clearCoreData: Bool = true,
        clearImageCache: Bool = true,
        disableSentry: Bool = true,
        disableSnowplow: Bool = true
    ) {
        self.clearKeychain = clearKeychain
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
}
