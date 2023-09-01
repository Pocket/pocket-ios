// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Localization
import SharedPocketKit
import WidgetKit

/// Service that saves an array of recent saves  to an `ItemWidgetsStore`
public struct RecentSavesWidgetUpdateService {
    private let store: ItemWidgetsStore
    /// Queue used to update values, to ensure subsequent calls always happen serially.
    /// Also prevents blocking execution at the caller site.
    private let savesUpdateQueue = DispatchQueue(label: "RecentSavesWidgetUpdateQueue", qos: .userInteractive)

    public init(store: ItemWidgetsStore) {
        self.store = store
    }

    /// Update the recent saves using the given array of `SavedItem`
    /// - Parameter items: the given array
    public func update(_ items: [SavedItem]) {
        let saves = items.map {
            ItemContent(
                url: $0.url,
                title: $0.item?.title ?? $0.url,
                imageUrl: $0.item?.topImageURL?.absoluteString,
                bestDomain: $0.item?.domainMetadata?.name ?? $0.item?.domain ?? URL(percentEncoding: $0.url)?.host ?? "",
                timeToRead: ($0.item?.timeToRead) != nil ? Int(truncating: ($0.item?.timeToRead)!) : nil
            )
        }
        let saveTopic = [ItemContentContainer(name: Localization.recentSaves, items: saves)]
        save(saveTopic)
    }

    private func save(_ saveTopic: [ItemContentContainer]) {
        // avoid triggering widget updates if stored data did not change
        guard store.topics != saveTopic else {
            return
        }
        savesUpdateQueue.async {
            do {
                try store.updateTopics(saveTopic)
                reloadWidget()
            } catch {
                Log.capture(message: "Failed to update recent saves for widget: \(error)")
            }
        }
    }

    public func insert(_ savedItem: SavedItem) {
        var currentItems = store.topics.first?.items ?? [ItemContent]()

        if let index = currentItems.firstIndex(where: { $0.url == savedItem.url }) {
            currentItems.remove(at: index)
        } else {
            currentItems.removeLast()
        }

        let newItem = ItemContent(
            url: savedItem.url,
            title: savedItem.item?.title ?? savedItem.url,
            imageUrl: savedItem.item?.topImageURL?.absoluteString,
            bestDomain: savedItem.item?.domainMetadata?.name ?? savedItem.item?.domain ?? URL(percentEncoding: savedItem.url)?.host ?? "",
            timeToRead: (savedItem.item?.timeToRead) != nil ? Int(truncating: (savedItem.item?.timeToRead)!) : nil
        )
        currentItems.insert(newItem, at: 0)

        let saveTopic = [ItemContentContainer(name: Localization.recentSaves, items: currentItems)]
        save(saveTopic)
    }

    /// Reloads the widget
    private func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.recentSaves)
    }
}
