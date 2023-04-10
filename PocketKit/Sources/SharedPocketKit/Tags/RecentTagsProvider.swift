// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation

public class RecentTagsProvider {
    private let userDefaults: UserDefaults
    private let key: UserDefaults.Key

    public init(userDefaults: UserDefaults, key: UserDefaults.Key) {
        self.userDefaults = userDefaults
        self.key = key
    }

    /// Handles the list of recent tags from userDefaults
    public var recentTags: [String] {
        get {
            userDefaults.stringArray(forKey: key) ?? []
        }
        set {
            userDefaults.set(Array(newValue.suffix(3)), forKey: key)
        }
    }

    /// Retrieve initial tags if userDefaults is empty
    /// - Parameter fetchedTags: user's list of tags
    public func getInitialRecentTags(with fetchedTags: [String]?) {
        if recentTags.isEmpty {
            let fetchedTags = fetchedTags ?? []
            recentTags = Array(fetchedTags.prefix(3))
        }
    }

    /// Update recent tags list after user adds tags to an item
    /// - Parameters:
    ///   - originalTags: list of tags originally associated with item
    ///   - inputTags: list of tags saved to the item
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
