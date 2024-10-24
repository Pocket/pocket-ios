// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import WidgetKit
import SwiftUI
import Textile
import Sync
import SharedPocketKit
import Localization

public struct RecommendationsWidget: Widget {
    let kind: String

    public init() {
        self.kind = WidgetKind.recommendations
    }

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ItemWidgetsProvider(service: ItemWidgetsService.makeRecommendationsService())) { entry in
                ItemWidgetsContainerView(entry: entry)
                .titleColor(entry.titleColor)
        }
        .configurationDisplayName(Localization.ItemWidgets.Recommendations.title)
        .description(Localization.ItemWidgets.Recommendations.description)
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemLarge) {
    RecommendationsWidget()
} timeline: {
    ItemsListEntry(date: Date(), name: "Pocket-Worthy Reads", contentType: .preview)
}
