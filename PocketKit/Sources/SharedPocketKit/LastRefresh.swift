import Foundation

public protocol LastRefresh {
    var lastRefreshSaves: Double? { get }
    var lastRefreshArchive: Double? { get }
    var lastRefreshTags: Double? { get }
    var lastRefreshHome: Double? { get }
    func refreshedSaves()
    func refreshedArchive()
    func refreshedTags()
    func refreshedHome()
    func reset()
}

public struct UserDefaultsLastRefresh: LastRefresh {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    public func reset() {
        defaults.set(nil, forKey: Self.lastRefreshedSavesAtKey)
        defaults.set(nil, forKey: Self.lastRefreshedArchiveAtKey)
        defaults.set(nil, forKey: Self.lastRefreshedTagsAtKey)
        defaults.set(nil, forKey: Self.lastRefreshedHomeAtKey)
    }
}

// MARK: Saves

extension UserDefaultsLastRefresh {
    private static let lastRefreshedSavesAtKey = "lastRefreshedSavesAt"

    public var lastRefreshSaves: Double? {
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
    private static let lastRefreshedArchiveAtKey = "lastRefreshedArchiveAt"

    public var lastRefreshArchive: Double? {
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
    private static let lastRefreshedTagsAtKey = "lastRefreshedTagsAt"

    public var lastRefreshTags: Double? {
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
    private static let lastRefreshedHomeAtKey = "lastRefreshedHomeAt"

    public var lastRefreshHome: Double? {
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
