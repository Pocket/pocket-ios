// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sentry


public struct Crashlogger {
    public static func setUserID(_ userID: String) {
        SentrySDK.setUser(User(userId: userID))
    }

    public static func clearUser() {
        SentrySDK.setUser(nil)
    }

    public static func capture(error: Error) {
        SentrySDK.capture(error: error)
    }

    public static func capture(message: String) {
        SentrySDK.capture(message: message)
    }

    public static func start(dsn: String) {
        SentrySDK.start { options in
            options.dsn = dsn
            options.enableAutoPerformanceTracking = false
            options.debug = true
        }
    }
}
