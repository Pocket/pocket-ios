// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


protocol LastRefresh {
    var lastRefresh: Int? { get }
    func refreshed()
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

    private static let lastRefreshedAtKey = "lastRefreshedAt"
}
