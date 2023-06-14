// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import WidgetKit
import SwiftUI
import Textile

public struct RecommendationsWidget: Widget {
    let kind: String

    public init() {
        self.kind = "DiscoverWidget"
    }

    public var body: some WidgetConfiguration {
        // TODO: Replace the provider
        StaticConfiguration(kind: kind, provider: RecentSavesProvider()) { entry in
            // TODO: add the actual view
            Text("Discover Widget Coming Soon!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.ui.homeCellBackground))
        }
        .configurationDisplayName("Discover")
        .description("Discover the most thought-provoking stories out there, curated by Pocket.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
