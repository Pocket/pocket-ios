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
        StaticConfiguration(kind: kind, provider: ItemWidgetsProvider(
            service: ItemWidgetsService.makeRecentSavesService(),
            tracker: WidgetTracker(defaults: ItemWidgetsService.makeUserDefaults())
        )) { entry in
            ItemsWidgetsContainerView(entry: entry)
                .titleColor(.ui.coral2)
        }
        .configurationDisplayName(Localization.ItemWidgets.RecentSaves.title)
        .description(Localization.ItemWidgets.RecentSaves.description)
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

public struct RecentSavesWidget_Previews: PreviewProvider {
    public static var previews: some View {
        ItemsWidgetsContainerView(entry: ItemsListEntry(date: Date(), name: "Recent Saves", contentType: .items([ItemRowContent(content: .placeHolder, image: nil)])))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
