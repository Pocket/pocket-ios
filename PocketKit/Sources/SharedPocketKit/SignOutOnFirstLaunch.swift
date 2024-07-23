// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class SignOutOnFirstLaunch {
    static let hasAppBeenLaunchedPreviouslyKey = UserDefaults.Key.hasAppBeenLaunchedPreviously

    private let appSession: AppSession
    private let user: User
    private let userDefaults: UserDefaults

    public init(
        appSession: AppSession,
        user: User,
        userDefaults: UserDefaults
    ) {
        self.appSession = appSession
        self.user = user
        self.userDefaults = userDefaults
    }

    private var hasAppBeenLaunchedPreviously: Bool {
        get {
            userDefaults.bool(forKey: Self.hasAppBeenLaunchedPreviouslyKey)
        }
        set {
            userDefaults.set(newValue, forKey: Self.hasAppBeenLaunchedPreviouslyKey)
        }
    }

    public func execute() {
        guard !hasAppBeenLaunchedPreviously else {
            return
        }

        user.clear()
        appSession.clearCurrentSession()
        hasAppBeenLaunchedPreviously = true
    }
}
