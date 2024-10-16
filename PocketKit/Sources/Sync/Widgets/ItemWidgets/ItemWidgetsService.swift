// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import WidgetKit

/// Service that reads items from a store
/// Items can be either recent saves or recommendations
public struct ItemWidgetsService {
    private let store: ItemWidgetsStore
    private let sessionService: WidgetsSessionService

    public var kind: ItemWidgetKind {
        store.kind
    }

    public var status: WidgetStatus {
        sessionService.status
    }

    public init(store: ItemWidgetsStore, sessionStore: WidgetsSessionService) {
        self.store = store
        self.sessionService = sessionStore
    }

    /// Returns the current items list, sliced at the specified limit.
    /// if limit is `0`, the full list is returned
    /// - Parameter limit: the specified limit
    /// - Returns: the list of items
    public func getTopics(limit: Int) -> [ItemContentContainer] {
        let topics = store.topics
        guard limit > 0 else {
            return topics
        }
        return topics.reduce(into: [ItemContentContainer]()) {
            $0.append(ItemContentContainer(name: $1.name, items: Array($1.items.prefix(limit))))
        }
    }

    /// Convenience property that returns if the user is logged in, false otherwise (including anonymous)
    /// Used for recent saves since they are not to be displayed in anonymous mode.
    public var isLoggedIn: Bool {
        status == .loggedIn
    }
}

// MARK: Widget-specific services
extension ItemWidgetsService {
    private static func makeUserDefaults() -> UserDefaults? {
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

    public static func makeRecommendationsService() -> ItemWidgetsService? {
        makeWidgetService(key: .recommendationsWidget)
    }
}
