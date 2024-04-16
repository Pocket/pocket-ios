// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import Sync
import SwiftUI
import Textile
import WidgetKit

@available(iOS 17.0, *)
struct TopicTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TopicEntry {
        return TopicEntry(date: Date(), content: TopicContent.sampleContent)
    }

    func snapshot(for configuration: TopicIntent, in context: Context) async -> TopicEntry {
        return TopicEntry(date: Date(), content: configuration.topicEntity.content)
    }

    func timeline(for configuration: TopicIntent, in context: Context) async -> Timeline<TopicEntry> {
        let entry = TopicEntry(date: Date(), content: configuration.topicEntity.content)

      return Timeline(entries: [entry], policy: .never)
    }
}
