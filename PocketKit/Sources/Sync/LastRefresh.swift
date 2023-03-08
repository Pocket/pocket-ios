import Foundation

protocol LastRefresh {
    var lastRefreshSaves: Int? { get }
    var lastRefreshArchive: Int? { get }
    func refreshedSaves()
    func refreshedArchive()
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
