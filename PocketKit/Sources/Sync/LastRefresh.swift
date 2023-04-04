import Foundation

protocol LastRefresh {
    var lastRefreshSaves: Int? { get }
    var lastRefreshArchive: Int? { get }
    var lastRefreshTags: Int? { get }
    func refreshedSaves()
    func refreshedArchive()
    func refreshedTags()
    func reset()
}

struct UserDefaultsLastRefresh: LastRefresh {
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func reset() {
        defaults.set(nil, forKey: Self.lastRefreshedSavesAtKey)
        defaults.set(nil, forKey: Self.lastRefreshedArchiveAtKey)
        defaults.set(nil, forKey: Self.lastRefreshedTagsAtKey)
    }
}

// MARK: Saves

extension UserDefaultsLastRefresh {
    private static let lastRefreshedSavesAtKey = "lastRefreshedSavesAt"

    var lastRefreshSaves: Int? {
        if hasRefreshedSaves {
            return defaults.integer(forKey: Self.lastRefreshedSavesAtKey)
        } else {
            return nil
        }
    }

    var hasRefreshedSaves: Bool {
        defaults.value(forKey: Self.lastRefreshedSavesAtKey) != nil
    }

    func refreshedSaves() {
        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastRefreshedSavesAtKey)
    }
}

// MARK: Archive
extension UserDefaultsLastRefresh {
    private static let lastRefreshedArchiveAtKey = "lastRefreshedArchiveAt"

    var lastRefreshArchive: Int? {
        if hasRefreshedArchive {
            return defaults.integer(forKey: Self.lastRefreshedArchiveAtKey)
        } else {
            return nil
        }
    }

    var hasRefreshedArchive: Bool {
        defaults.value(forKey: Self.lastRefreshedArchiveAtKey) != nil
    }

    func refreshedArchive() {
        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastRefreshedArchiveAtKey)
    }
}

// MARK: Tags
extension UserDefaultsLastRefresh {
    private static let lastRefreshedTagsAtKey = "lastRefreshedTagsAt"

    var lastRefreshTags: Int? {
        if hasRefreshedArchive {
            return defaults.integer(forKey: Self.lastRefreshedTagsAtKey)
        } else {
            return nil
        }
    }

    var hasRefreshedTags: Bool {
        defaults.value(forKey: Self.lastRefreshedTagsAtKey) != nil
    }

    func refreshedTags() {
        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastRefreshedTagsAtKey)
    }
}
