// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sentry

public struct Crashlogger {
    public enum Level: UInt {
        case none = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
        case fatal = 5
    }

    public static func setUserID(_ userID: String) {
        SentrySDK.setUser(User(userId: userID))
    }

    public static func clearUser() {
        SentrySDK.setUser(nil)
    }

    public static func capture(error: Error) {
        print("Error: \(error.localizedDescription)")
        SentrySDK.capture(error: error)
    }

    public static func capture(message: String) {
        SentrySDK.capture(message: message)
    }

    public static func start(dsn: String) {
        if isRunningTests() {
            // We are in a test environment, lets not init sentry.
            return
        }

        SentrySDK.start { options in
            options.dsn = dsn
            options.enableAutoSessionTracking = true
            #if DEBUG
            options.debug = true
            #endif
        }
    }

    public static func breadcrumb(category: String, level: Level, message: String) {
        let crumb = Breadcrumb()
        crumb.category = category
        crumb.level = SentryLevel(rawValue: level.rawValue) ?? .none
        crumb.message = message

        SentrySDK.addBreadcrumb(crumb: crumb)
    }

    /**
     Utility to determine if we are in a test environment.
     */
    public static func isRunningTests() -> Bool {
        let env: [String: String] = ProcessInfo.processInfo.environment
        return env["XCInjectBundleInto"] != nil
    }
}
