// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile
import WidgetKit
import Sync
import SharedPocketKit

public struct RecentSavesWidget: Widget {
    let kind: String

    public init() {
        self.kind = WidgetKind.recentSaves
    }

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ItemWidgetsProvider(service: ItemWidgetsService.makeRecentSavesService())) { entry in
            ItemWidgetsContainerView(entry: entry)
                .titleColor(entry.titleColor)
        }
        .configurationDisplayName(Localization.ItemWidgets.RecentSaves.title)
        .description(Localization.ItemWidgets.RecentSaves.description)
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemLarge) {
    RecentSavesWidget()
} timeline: {
    ItemsListEntry(date: Date(), name: "Recent Saves", contentType: .preview)
}
