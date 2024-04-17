// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import SwiftUI
import WidgetKit

struct TopicEntry: TimelineEntry {
    let date: Date
    let content: TopicContent
}

struct TopicContent: Identifiable, Equatable {
    var id = UUID()
    let name: String
    let items: [ItemRowContent]
}

extension TopicContent {
    static var sampleContent: TopicContent {
        TopicContent(
            name: "Sample Topic",
            items: [
                ItemRowContent(
                    content: ItemContent(
                        url: "https://getPocket.com",
                        title: "Sample Entry",
                        imageUrl: nil,
                        bestDomain: "https://getPocket.com",
                        timeToRead: 0
                    ),
                    image: nil
                )
            ]
        )
    }
}
