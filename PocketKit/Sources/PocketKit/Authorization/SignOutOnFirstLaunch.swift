// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync


class SignOutOnFirstLaunch {
    private let accessTokenStore: AccessTokenStore
    private let userDefaults: UserDefaults

    static let hasAppBeenLaunchedPreviouslyKey = "hasAppBeenLaunchedPreviously"

    init(
        accessTokenStore: AccessTokenStore,
        userDefaults: UserDefaults
    ) {
        self.accessTokenStore = accessTokenStore
        self.userDefaults = userDefaults
    }

    var hasAppBeenLaunchedPreviously: Bool {
        get {
            userDefaults.bool(forKey: Self.hasAppBeenLaunchedPreviouslyKey)
        }
        set {
            userDefaults.set(newValue, forKey: Self.hasAppBeenLaunchedPreviouslyKey)
        }
    }

    func signOutOnFirstLaunch() {
        guard !hasAppBeenLaunchedPreviously else {
            return
        }

        do {
            try accessTokenStore.delete()
        } catch {
            Crashlogger.capture(error: error)
        }

        hasAppBeenLaunchedPreviously = true
    }
}
