// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI

public extension UserDefaults {
    enum Key: String, CaseIterable {
        case hasAppBeenLaunchedPreviously = "hasAppBeenLaunchedPreviously"
        case recentSearches = "Search.recentSearches"
        case recentTags = "Search.recentTags"
        case toggleAppBadge = "AccountViewModel.ToggleAppBadge"
        case appBadgeToggle = "Settings.ToggleAppBadge"
        case legacyUserMigration = "com.mozilla.pocket.next.migration.legacyUser"
        case dateLastRefresh = "HomeRefreshCoordinator.dateLastRefreshKey"
        case lastRefreshedTagsAt = "lastRefreshedTagsAt"
        case lastRefreshedArchiveAt = "lastRefreshedArchiveAt"
        case lastRefreshedSavesAt = "lastRefreshedSavesAt"
        case lastRefreshedHomeAt = "lastRefreshedHomeAt"
        case lastRefreshedFeatureFlagsAt = "lastRefreshedFeatureFlagsAt"
        case listSelectedSortForSaved = "listSelectedSortForSaved"
        case listSelectedSortForArchive = "listSelectedSortForArchive"
        case readerFontSizeAdjustment = "readerFontSizeAdjustment"
        case readerFontFamily = "readerFontFamily"
        case dateLastOpened = "dateLastOpened"
        case dateLastBackgrounded = "dateLastBackgrounded"
        case userStatus = "User.statusKey"
        case userName = "User.nameKey"
        case displayName = "User.displayNameKey"
        case userEmail = "User.email"
        case userId = "User.userId"
        case startingAppSection = "MainViewModel.StartingAppSection"
        case widgetsLoggedIn = "RecentSavesWidgetLoggedInKey"
        case recentSavesWidget = "RecentSavesWidgetKey"

        var isRemovable: Bool {
            switch self {
            case .hasAppBeenLaunchedPreviously: return false // This must remain in-tact for the "SignOutOnFirstLaunch" to be run exactly one time per app install
            case .legacyUserMigration: return false // We want to maintain the state of whether the migration has already been run
            default: return true
            }
        }
    }

    func resetKeys() {
        UserDefaults.Key.allCases
            .filter { $0.isRemovable }
            .forEach { removeObject(forKey: $0) }
    }
}

public extension UserDefaults {
    func set(_ value: Any?, forKey key: UserDefaults.Key) {
        set(value, forKey: key.rawValue)
    }

    func setValue(_ value: Any?, forKey key: UserDefaults.Key) {
        setValue(value, forKey: key.rawValue)
    }

    func bool(forKey key: UserDefaults.Key) -> Bool {
        return bool(forKey: key.rawValue)
    }

    func stringArray(forKey key: UserDefaults.Key) -> [String]? {
        return stringArray(forKey: key.rawValue)
    }

    func object(forKey key: UserDefaults.Key) -> Any? {
        return object(forKey: key.rawValue)
    }

    func string(forKey key: UserDefaults.Key) -> String? {
        return string(forKey: key.rawValue)
    }

    func integer(forKey key: UserDefaults.Key) -> Int {
        return integer(forKey: key.rawValue)
    }

    func double(forKey key: UserDefaults.Key) -> Double {
        return double(forKey: key.rawValue)
    }

    func value(forKey key: UserDefaults.Key) -> Any? {
        return value(forKey: key.rawValue)
    }

    func removeObject(forKey key: UserDefaults.Key) {
        removeObject(forKey: key.rawValue)
    }
}

public extension AppStorage {
    init(wrappedValue: Value, _ key: UserDefaults.Key, store: UserDefaults? = nil) where Value: RawRepresentable, Value.RawValue == String {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaults.Key, store: UserDefaults? = nil) where Value == Int {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaults.Key, store: UserDefaults? = nil) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaults.Key, store: UserDefaults? = nil) where Value == String {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init<R>(_ key: UserDefaults.Key, store: UserDefaults? = nil) where Value == R?, R: RawRepresentable, R.RawValue == String {
        self.init(key.rawValue, store: store)
    }
}
