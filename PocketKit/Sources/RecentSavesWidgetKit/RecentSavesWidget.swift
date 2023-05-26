// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import WidgetKit
import SwiftUI

public struct RecentSavesWidget: Widget {
    let kind: String

    public init() {
        self.kind = "RecentSavesWidget"
    }

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RecentSavesProvider()) { entry in
            RecentSavesView(entry: entry)
        }
        .configurationDisplayName("RecentSaves")
        .description("Access your most recently saved articles.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

public struct RecentSavesWidget_Previews: PreviewProvider {
    public static var previews: some View {
        RecentSavesView(entry: RecentSavesEntry(date: Date(), content: [.placeHolder]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
