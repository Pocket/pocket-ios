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
    public func getInitialRecentTags(with fetchedTags: [String]) {
        if recentTags.isEmpty {
            recentTags = Array(fetchedTags.prefix(3))
        }
    }

    /// Update recent tags list after user adds tags to an item by comparing the original tags associated with the item with the updated tags associated with the item
    /// - Parameters:
    ///   - originalTags: list of tags originally associated with item before any updates from the user
    ///   - updatedTags: updated list of tags associated with the items after the user taps save in add tags view
    public func updateRecentTags(with originalTags: [String], and updatedTags: [String]) {
        var newTags = updatedTags

        // Filter out the tags from the list of updated tags that also exist in the original tags for the item
        if !originalTags.isEmpty {
            newTags = updatedTags.filter { !originalTags.contains($0) }
        }

        // Check if new tags list should be added to recent tags
        newTags.forEach { tag in
            guard !recentTags.contains(tag) else { return }
            recentTags.append(tag)
        }
    }
}
