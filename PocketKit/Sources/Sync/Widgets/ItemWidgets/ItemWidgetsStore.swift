// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SharedPocketKit
import WidgetKit

enum RecentSavesStoreError: Error {
    case invalidStorage
}

/// A store that provides a list of recent saves
public protocol ItemWidgetsStore {
    var Items: ItemContentContainer { get }
    func updateItems(_ items: [ItemContent], _ name: String) throws
}

/// A concrete implementation of `ItemWidgetsStore` that uses `UserDefaults` as local storage
public struct UserDefaultsItemWidgetsStore: ItemWidgetsStore {
    private let defaults: UserDefaults
    private let key: UserDefaults.Key

    /// Current recent saves list
    public var Items: ItemContentContainer {
        guard let encodedSaves = defaults.object(forKey: key) as? Data,
                let saves = try? JSONDecoder().decode(ItemContentContainer.self, from: encodedSaves) else {
            return ItemContentContainer.empty
        }
        return saves
    }

    public init(userDefaults: UserDefaults, key: UserDefaults.Key) {
        self.defaults = userDefaults
        self.key = key
    }

    /// Update the recent saves list with the given list
    /// - Parameter items: the given list
    public func updateItems(_ items: [ItemContent], _ name: String) throws {
        let itemsContainer = ItemContentContainer(name: name, items: items)
        let encodedList = try JSONEncoder().encode(itemsContainer)
        defaults.setValue(encodedList, forKey: key)
    }
}
