// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public protocol LastRefresh {
    var lastRefreshSaves: TimeInterval? { get }
    var lastRefreshArchive: TimeInterval? { get }
    var lastRefreshTags: TimeInterval? { get }
    var lastRefreshHome: TimeInterval? { get }
    var lastRefreshFeatureFlags: TimeInterval? { get }
    // we use the ISO8601 String representation in this case
    var lastRefreshNotes: String? { get }
    func refreshedSaves()
    func refreshedArchive()
    func refreshedTags()
    func refreshedHome()
    func refreshedFeatureFlags()
    func refreshedNotes()
    func reset()
}

public struct UserDefaultsLastRefresh: LastRefresh {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    public func reset() {
        defaults.removeObject(forKey: Self.lastRefreshedSavesAtKey)
        defaults.removeObject(forKey: Self.lastRefreshedArchiveAtKey)
        defaults.removeObject(forKey: Self.lastRefreshedTagsAtKey)
        defaults.removeObject(forKey: Self.lastRefreshedHomeAtKey)
        defaults.removeObject(forKey: Self.lastRefreshedFeatureFlagsAtKey)
        defaults.removeObject(forKey: Self.lastRefreshedNotesAtKey)
    }
}

// MARK: Saves
extension UserDefaultsLastRefresh {
    public static let lastRefreshedSavesAtKey = UserDefaults.Key.lastRefreshedSavesAt

    public var lastRefreshSaves: TimeInterval? {
        if hasRefreshedSaves {
            return defaults.double(forKey: Self.lastRefreshedSavesAtKey)
        } else {
            return nil
        }
    }

    public var hasRefreshedSaves: Bool {
        defaults.value(forKey: Self.lastRefreshedSavesAtKey) != nil
    }

    public func refreshedSaves() {
        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastRefreshedSavesAtKey)
    }
}

// MARK: Archive
extension UserDefaultsLastRefresh {
    public static let lastRefreshedArchiveAtKey = UserDefaults.Key.lastRefreshedArchiveAt

    public var lastRefreshArchive: TimeInterval? {
        if hasRefreshedArchive {
            return defaults.double(forKey: Self.lastRefreshedArchiveAtKey)
        } else {
            return nil
        }
    }

    public var hasRefreshedArchive: Bool {
        defaults.value(forKey: Self.lastRefreshedArchiveAtKey) != nil
    }

    public func refreshedArchive() {
        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastRefreshedArchiveAtKey)
    }
}

// MARK: Tags
extension UserDefaultsLastRefresh {
    public static let lastRefreshedTagsAtKey = UserDefaults.Key.lastRefreshedTagsAt

    public var lastRefreshTags: TimeInterval? {
        if hasRefreshedTags {
            return defaults.double(forKey: Self.lastRefreshedTagsAtKey)
        } else {
            return nil
        }
    }

    public var hasRefreshedTags: Bool {
        defaults.value(forKey: Self.lastRefreshedTagsAtKey) != nil
    }

    public func refreshedTags() {
        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastRefreshedTagsAtKey)
    }
}

// MARK: Home
extension UserDefaultsLastRefresh {
    public static let lastRefreshedHomeAtKey = UserDefaults.Key.lastRefreshedHomeAt

    public var lastRefreshHome: TimeInterval? {
        if hasRefreshedHome {
            return defaults.double(forKey: Self.lastRefreshedHomeAtKey)
        } else {
            return nil
        }
    }

    public var hasRefreshedHome: Bool {
        defaults.value(forKey: Self.lastRefreshedHomeAtKey) != nil
    }

    public func refreshedHome() {
        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastRefreshedHomeAtKey)
    }
}

// MARK: Feature flags
extension UserDefaultsLastRefresh {
    public static let lastRefreshedFeatureFlagsAtKey = UserDefaults.Key.lastRefreshedFeatureFlagsAt

    public var lastRefreshFeatureFlags: TimeInterval? {
        if hasRefreshedFeatureFlags {
            return defaults.double(forKey: Self.lastRefreshedFeatureFlagsAtKey)
        } else {
            return nil
        }
    }

    public var hasRefreshedFeatureFlags: Bool {
        defaults.value(forKey: Self.lastRefreshedFeatureFlagsAtKey) != nil
    }

    public func refreshedFeatureFlags() {
        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastRefreshedFeatureFlagsAtKey)
    }
}

// MARK: Notes
extension UserDefaultsLastRefresh {
    public static let lastRefreshedNotesAtKey = UserDefaults.Key.lastRefreshNotesAt

    public var lastRefreshNotes: String? {
        if hasRefreshedNotes {
            return defaults.string(forKey: Self.lastRefreshedNotesAtKey)
        } else {
            return nil
        }
    }

    public var hasRefreshedNotes: Bool {
        defaults.value(forKey: Self.lastRefreshedNotesAtKey) != nil
    }

    public func refreshedNotes() {
        defaults.set(ISO8601DateFormatter.rfc3339WithFractionalSeconds.string(from: Date()), forKey: Self.lastRefreshedNotesAtKey)
    }
}

private extension ISO8601DateFormatter {
    static var rfc3339WithFractionalSeconds: Self {
        let formatter = Self()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}
