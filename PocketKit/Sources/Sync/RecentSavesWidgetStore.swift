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
    var isLoggedIn: Bool { get }
    func setLoggedIn(_ isLoggedIn: Bool)
    var recentSaves: [SavedItemContent] { get }
    func updateRecentSaves(_ items: [SavedItemContent]) throws
}

/// A concrete implementation of `RecentSavesStore` used for the recent saves widget
public struct RecentSavesWidgetStore: RecentSavesStore {
    private static let isLoggedInKey = "RecentSavesWidgetLoggedInKey"
    private static let recentSavesKey = "RecentSavesWidgetKey"
    private static let groupID = "group.com.ideashower.ReadItLaterPro"

    private var defaults: UserDefaults

    /// Current recent saves list
    public var recentSaves: [SavedItemContent] {
        guard let encodedSaves = defaults.object(forKey: Self.recentSavesKey) as? Data,
                let saves = try? JSONDecoder().decode([SavedItemContent].self, from: encodedSaves) else {
            return []
        }
        return saves
    }

    /// Current logged in status
    public var isLoggedIn: Bool {
        defaults.bool(forKey: Self.isLoggedInKey)
    }

    public init(userDefaults: UserDefaults) {
        self.defaults = userDefaults
    }

    /// Update the recent saves list with the given list
    /// - Parameter items: the given list
    public func updateRecentSaves(_ items: [SavedItemContent]) throws {
        let encodedList = try JSONEncoder().encode(items)
        defaults.setValue(encodedList, forKey: Self.recentSavesKey)
    }

    /// Sets the logged in status
    /// - Parameter isLoggedIn: the logged in status to set
    public func setLoggedIn(_ isLoggedIn: Bool) {
        defaults.setValue(isLoggedIn, forKey: Self.isLoggedInKey)
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

    /// True if the user is logged in, false otherwise
    public var isLoggedIn: Bool {
        store.isLoggedIn
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

    /// Set the recent saves list to the given list
    /// - Parameter items: the given list
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
                reloadWidget()
            } catch {
                Log.capture(message: "Failed to update recent saves for widget: \(error)")
            }
        }
    }

    /// Sets the logged in status
    /// - Parameter isloggedIn: the logged in status
    public func setLoggedIn(_ isloggedIn: Bool) {
        store.setLoggedIn(isloggedIn)
        reloadWidget()
    }

    /// Reloads the widget
    private func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "RecentSavesWidget")
    }
}
