// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SharedPocketKit
import WidgetKit

public enum ItemWidgetKind {
    case recentSaves
    case recommendations
    case unknown
}

/// A store that provides a list of topics for the item widgets
public protocol ItemWidgetsStore {
    // a topic is a collection of items,
    // like recent saves or any recommendation's slate
    var topics: [ItemContentContainer] { get }
    var kind: ItemWidgetKind { get }
    func updateTopics(_ topics: [ItemContentContainer]) throws
}

/// A concrete implementation of `ItemWidgetsStore` that uses `UserDefaults` as local storage
public struct UserDefaultsItemWidgetsStore: ItemWidgetsStore {
    private let defaults: UserDefaults
    private let key: UserDefaults.Key

    public var kind: ItemWidgetKind {
        switch key {
        case .recentSavesWidget:
            return .recentSaves
        case .recommendationsWidget:
            return .recommendations
        default:
            return .unknown
        }
    }

    /// Current recent saves list
    public var topics: [ItemContentContainer] {
        guard let encodedTopics = defaults.object(forKey: key) as? Data,
                let topics = try? JSONDecoder().decode([ItemContentContainer].self, from: encodedTopics) else {
            return []
        }
        return topics
    }

    public init(userDefaults: UserDefaults, key: UserDefaults.Key) {
        self.defaults = userDefaults
        self.key = key
    }

    /// Update the recent saves list with the given list
    /// - Parameter items: the given list
    public func updateTopics(_ topics: [ItemContentContainer]) throws {
        let encodedList = try JSONEncoder().encode(topics)
        defaults.setValue(encodedList, forKey: key)
    }
}
