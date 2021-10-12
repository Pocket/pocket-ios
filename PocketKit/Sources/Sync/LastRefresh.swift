import Foundation


protocol LastRefresh {
    var lastRefresh: Int? { get }
    func refreshed()
    func reset()
}

struct UserDefaultsLastRefresh: LastRefresh {
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    var lastRefresh: Int? {
        if hasRefreshed {
            return defaults.integer(forKey: Self.lastRefreshedAtKey)
        } else {
            return nil
        }
    }

    var hasRefreshed: Bool {
        defaults.value(forKey: Self.lastRefreshedAtKey) != nil
    }

    func refreshed() {
        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastRefreshedAtKey)
    }

    func reset() {
        defaults.set(nil, forKey: Self.lastRefreshedAtKey)
    }

    private static let lastRefreshedAtKey = "lastRefreshedAt"
}
