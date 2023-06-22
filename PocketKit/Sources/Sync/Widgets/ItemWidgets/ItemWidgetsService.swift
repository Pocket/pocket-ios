// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import WidgetKit

/// Service that reads recent saves from a store
public struct ItemWidgetsService {
    private let store: ItemWidgetsStore
    private let sessionService: WidgetsSessionService

    public var kind: ItemWidgetKind {
        store.kind
    }

    public init(store: ItemWidgetsStore, sessionStore: WidgetsSessionService) {
        self.store = store
        self.sessionService = sessionStore
    }

    /// Returns the current recent saves list, sliced at the specified limit.
    /// if limit is `0`, the full list is returned
    /// - Parameter limit: the specified limit
    /// - Returns: the list of items
    public func getItems(limit: Int) -> ItemContentContainer {
        let saves = store.Items
        let items = limit > 0 ? Array(saves.items.prefix(min(saves.items.count, limit))) : saves.items
        return ItemContentContainer(name: saves.name, items: items)
    }

    /// True if the user is logged in
    public var isLoggedIn: Bool {
        sessionService.isLoggedIn
    }
}

// MARK: Widget-specific services
extension ItemWidgetsService {
    public static func makeUserDefaults() -> UserDefaults? {
        guard let info = Bundle.main.infoDictionary,
              let groupID = info["GroupId"] as? String,
              let defaults = UserDefaults(suiteName: groupID) else {
            Log.capture(message: "Item widget: unable to initialize a shared user defaults instance")
            return nil
        }
        return defaults
    }

    private static func makeWidgetService(key: UserDefaults.Key) -> ItemWidgetsService? {
        guard let defaults = makeUserDefaults() else {
            return nil
        }
        return ItemWidgetsService(store: UserDefaultsItemWidgetsStore(userDefaults: defaults, key: key), sessionStore: UserDefaultsWidgetSessionService(defaults: defaults))
    }

    public static func makeRecentSavesService() -> ItemWidgetsService? {
        makeWidgetService(key: .recentSavesWidget)
    }

    public static func makeEditorsPicksService() -> ItemWidgetsService? {
        makeWidgetService(key: .recommendationsWidget)
    }
}
