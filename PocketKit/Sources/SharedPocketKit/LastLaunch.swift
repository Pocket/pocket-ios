// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public protocol LastLaunchedAppVersion {
    var lastLaunch: LastLaunchedAppVersionData? { get }
    func launched()
    func reset()
}

public struct LastLaunchedAppVersionData: Codable {
    public var appBuild: String
    public var appVersion: Version
    public var date: Date

    public static func current() -> LastLaunchedAppVersionData {
        return LastLaunchedAppVersionData(
            appBuild: Bundle.main.appBuild,
            appVersion: Bundle.main.appVersion,
            date: Date()
        )
    }
}

public struct UserDefaultsLastLaunchedAppVersion: LastLaunchedAppVersion {
    public static let lastLaunchedAppVersionKey = UserDefaults.Key.lastLaunchedAppVersion

    private let defaults: UserDefaults

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    public func reset() {
        defaults.set(nil, forKey: Self.lastLaunchedAppVersionKey)
    }

    /**
     Called when the app has finished all launch tasks to register that the current app version, is now the last launched version
     */
    public func launched() {
       do {
        defaults.set(try JSONEncoder().encode(LastLaunchedAppVersionData.current()), forKey: Self.lastLaunchedAppVersionKey)
       } catch {
           Log.breadcrumb(category: "last-launch", level: .info, message: "Could not encode app version for user defaults")
           Log.capture(error: error)
       }
    }

    /**
    Gets the lasted launched data object from user defaults, otherwise return the current version of the app as last launched
     */
    public var lastLaunch: LastLaunchedAppVersionData? {
        guard let encodedData = defaults.value(forKey: Self.lastLaunchedAppVersionKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(LastLaunchedAppVersionData.self, from: encodedData as! Data)
        } catch {
            Log.breadcrumb(category: "last-launch", level: .info, message: "Could not decode app version from user defaults")
            Log.capture(error: error)
            return nil
        }
    }
}
