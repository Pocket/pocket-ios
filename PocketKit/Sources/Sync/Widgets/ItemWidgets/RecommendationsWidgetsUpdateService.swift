// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Localization
import SharedPocketKit
import WidgetKit

/// Service that saves a recommendations slate to an `ItemWidgetsStore`
///  Can be used for any slate.
public struct RecommendationsWidgetUpdateService {
    private let store: ItemWidgetsStore
    /// Queue used to update values, to ensure subsequent calls always happen serially.
    /// Also prevents blocking execution at the caller site.
    private let recommendationsUpdateQueue = DispatchQueue(label: "RecommendationWidgetUpdateQueue", qos: .userInteractive)

    public init(store: ItemWidgetsStore) {
        self.store = store
    }

    /// Update the recommendations using a collection of slates, normalized to `[String: [Recommendation]]`
    /// - Parameter items: the given collection of normalized slates
    public func update(_ topics: [String: [Recommendation]]) {
        let newTopics: [ItemContentContainer] = topics.map { makeItemContentContainer($0.key, $0.value) }
        // avoid triggering widget updates if stored data did not change
        guard (store.topics.sorted { $0.name > $1.name }) != (newTopics.sorted { $0.name > $1.name }) else {
            return
        }
        recommendationsUpdateQueue.async {
            do {
                try store.updateTopics(newTopics)
                reloadWidget()
            } catch {
                Log.capture(message: "Failed to update recommendations for widget: \(error)")
            }
        }
    }

    private func makeItemContentContainer(_ name: String, _ recommendations: [Recommendation]) -> ItemContentContainer {
            let itemContent = recommendations.map {
                ItemContent(
                    url: $0.item.givenURL,
                    title: $0.item.title ?? $0.item.givenURL,
                    imageUrl: $0.item.topImageURL?.absoluteString,
                    bestDomain: $0.item.domainMetadata?.name ?? $0.item.domain ?? URL(percentEncoding: $0.item.bestURL)?.host ?? "",
                    timeToRead: ($0.item.timeToRead) != nil ? Int(truncating: ($0.item.timeToRead)!) : nil
                )
            }
            return ItemContentContainer(name: name, items: itemContent)
    }

    /// Reloads the widget
    private func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.recommendations)
    }
}
