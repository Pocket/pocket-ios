// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import WidgetKit

enum RecentSavesStoreError: Error {
    case invalidStorage
}

/// A store that provides a list of recent saves
public protocol RecentSavesStore {
    var recentSaves: [SavedItemContent] { get }
    func updateRecentSaves(_ items: [SavedItemContent]) throws
}

/// A concrete implementation of `RecentSavesStore` used for the recent saves widget
public struct RecentSavesWidgetStore: RecentSavesStore {
    private static let recentSavesKey = "RecentSavesWidgetKey"
    private static let groupID = "group.com.ideashower.ReadItLaterPro"

    private var defaults: UserDefaults

    public var recentSaves: [SavedItemContent] {
        guard let encodedSaves = defaults.object(forKey: Self.recentSavesKey) as? Data,
                let saves = try? JSONDecoder().decode([SavedItemContent].self, from: encodedSaves) else {
            return []
        }
        return saves
    }

    public init(userDefaults: UserDefaults) {
        self.defaults = userDefaults
    }

    public func updateRecentSaves(_ items: [SavedItemContent]) throws {
        let encodedList = try JSONEncoder().encode(items)
        defaults.setValue(encodedList, forKey: Self.recentSavesKey)
    }
}

/// Service that reads recent saves from a store
public struct RecentSavesWidgetService {
    private let store: RecentSavesStore

    public init(store: RecentSavesStore) {
        self.store = store
    }

    /// Returns the current recent saves list, sliced at the specified limit.
    /// if limit is `0`, the full list is returned
    /// - Parameter limit: the specified limit
    /// - Returns: the list of items
    public func getRecentSaves(limit: Int) -> [SavedItemContent] {
        let saves = store.recentSaves
        return limit > 0 ? Array(saves.prefix(min(saves.count, limit))) : saves
    }
}

/// Service that updates recent saves to a store
public struct RecentSavesWidgetUpdateService {
    private let store: RecentSavesStore
    /// Queue used to update values, to ensure subsequent calls always happen serially.
    /// Also prevents blocking execution at the caller site.
    private let savesUpdateQueue = DispatchQueue(label: "RecentSavesWidgetUpdateQueue", qos: .userInteractive)

    public init(store: RecentSavesStore) {
        self.store = store
    }

    public func setRecentSaves(_ items: [SavedItem]) {
        savesUpdateQueue.async {
            let saves = items.map {
                SavedItemContent(url: $0.url.absoluteString,
                                 title: $0.item?.title ?? $0.url.absoluteString,
                                 imageUrl: $0.item?.topImageURL?.absoluteString)
            }
            // avoid triggering widget updates if stored data did not change
            guard store.recentSaves != saves else {
                return
            }

            do {
                try store.updateRecentSaves(saves)
                WidgetCenter.shared.reloadTimelines(ofKind: "RecentSavesWidget")
            } catch {
                Log.capture(message: "Failed to update recent saves for widget: \(error)")
            }
        }
    }
}
