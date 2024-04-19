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
    func placeholder(in context: Context) -> ItemsListEntry {
        let content = ItemsWidgetContent.sampleContent
        return ItemsListEntry(date: Date(), name: content.name, contentType: content.contentType)
    }

    func snapshot(for configuration: TopicIntent, in context: Context) async -> ItemsListEntry {
        let content = configuration.topicEntity.topic
        return ItemsListEntry(date: Date(), name: content.name, contentType: content.contentType)
    }

    func timeline(for configuration: TopicIntent, in context: Context) async -> Timeline<ItemsListEntry> {
        let content = configuration.topicEntity.topic
        let entry = ItemsListEntry(date: Date(), name: content.name, contentType: content.contentType)

      return Timeline(entries: [entry], policy: .never)
    }
}
