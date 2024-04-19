// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import AppIntents

@available(iOS 17.0, *)
struct TopicIntent: WidgetConfigurationIntent {
    // NOTE: strings are hardcoded because LocalizedStringResource does not support SwiftGen. The only untranslated
    // string visible to the user in the widget it the "Topic" label when they choose a topic.
    static var title: LocalizedStringResource = "Select Topic"
    static var description: IntentDescription? = IntentDescription(stringLiteral: "Select a topic to see recommendations.")
    @Parameter(title: "Topic")
    var topicEntity: TopicEntity

    init(topicEntity: TopicEntity) {
        self.topicEntity = topicEntity
    }

    init() {}
}
