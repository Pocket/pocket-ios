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

    /// Updates the recommendations using the given array of `Recommendation`
    /// - Parameter items: the given array
    public func update(_ items: [Recommendation]) {
        recommendationsUpdateQueue.async {
            let recommendations = items.map {
                ItemContent(
                    url: $0.item.givenURL.absoluteString,
                    title: $0.item.title ?? $0.item.givenURL.absoluteString,
                    imageUrl: $0.item.topImageURL?.absoluteString,
                    bestDomain: $0.item.domainMetadata?.name ?? $0.item.domain ?? $0.item.givenURL.host ?? "",
                    timeToRead: ($0.item.timeToRead) != nil ? Int(truncating: ($0.item.timeToRead)!) : nil
                )
            }
            var name = Localization.Widgets.Recommendations.fallbackTitle
            if let item = items.first, let slateName = item.slate?.name {
                name = slateName
            }
            let savesContainer = ItemContentContainer(name: name, items: recommendations)
            // avoid triggering widget updates if stored data did not change
            guard store.Items != savesContainer else {
                return
            }

            do {
                try store.updateItems(recommendations, name)
                reloadWidget()
            } catch {
                Log.capture(message: "Failed to update recommendations for widget: \(error)")
            }
        }
    }

    /// Reloads the widget
    private func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.editorsPicks)
    }
}
