// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import WidgetKit
import SwiftUI
import Textile
import Sync
import SharedPocketKit
import Localization

@available(iOS 17.0, *)
public struct TopicRecommendationsWidget: Widget {
    let kind: String

    public init() {
        self.kind = WidgetKind.topicRecommendations
    }

    public var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: TopicIntent.self, provider: TopicTimelineProvider()) { entry in
            TopicidgetContainerView(entry: entry)
        }
        .configurationDisplayName("New Recommendations")
        .description("Select a Topic")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
