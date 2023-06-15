// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile
import WidgetKit

public struct RecentSavesWidget: Widget {
    let kind: String

    public init() {
        self.kind = "RecentSavesWidget"
    }

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RecentSavesProvider()) { entry in
            makeRecentSavesView(entry: entry)
        }
        .configurationDisplayName(Localization.Widgets.RecentSaves.title)
        .description(Localization.Widget.RecentSaves.description)
        .supportedFamilies([.systemMedium, .systemLarge])
    }

    @ViewBuilder
    private func makeRecentSavesView(entry: RecentSavesProvider.Entry) -> some View {
        if #available(iOS 17.0, *) {
            ItemsListView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .containerBackground(for: .widget) {
                    Color(.ui.white1)
                }
        } else {
            ItemsListView(entry: entry)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.ui.white1))
        }
    }
}

public struct RecentSavesWidget_Previews: PreviewProvider {
    public static var previews: some View {
        ItemsListView(entry: ItemsListEntry(date: Date(), contentType: .items([ItemRowContent(content: .placeHolder, image: nil)])))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
