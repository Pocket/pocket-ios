// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import AppIntents

struct TopicEntity: AppEntity {
    var topic: ItemsWidgetContent
    var id: String { "\(topic.name)" }
    static var defaultQuery = TopicQuery()
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Topic"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(topic.name)")
    }
}
