// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation

public class RecentTagsFactory {
    private let userDefaults: UserDefaults
    private let key: String

    public init(userDefaults: UserDefaults, key: String) {
        self.userDefaults = userDefaults
        self.key = key
    }

    public var recentTags: [String] {
        get {
            userDefaults.stringArray(forKey: key) ?? []
        }
        set {
            let tags = newValue
            userDefaults.set(Array(tags.prefix(3)), forKey: key)
        }
    }

    public func getInitialRecentTags(with fetchedTags: [String]?) {
        if recentTags.isEmpty {
            let fetchedTags = fetchedTags ?? []
            recentTags = Array(fetchedTags.prefix(3))
        }
    }

    public func updateRecentTags(with originalTags: [String]?, and inputTags: [String]) {
       var newTags = inputTags
       if let originalTags {
           newTags = inputTags.filter { !originalTags.contains($0) }
       }
       newTags.forEach { tag in
           guard !recentTags.contains(tag) else { return }
           recentTags.append(tag)
       }
   }
}
