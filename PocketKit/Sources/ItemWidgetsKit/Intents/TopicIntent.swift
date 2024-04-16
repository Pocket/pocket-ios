// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import AppIntents
import Localization
import WidgetKit

@available(iOS 17.0, *)
struct TopicIntent: WidgetConfigurationIntent {
    // TODO: verify the correct way to use LocalizedStringResource with SwiftGen
    static var title = LocalizedStringResource(
        stringLiteral: Localization
            .ItemWidgets
            .Recommendations
            .SelectableTopic
            .title
    )
    static var description = LocalizedStringResource(
        stringLiteral: Localization
            .ItemWidgets
            .Recommendations
            .SelectableTopic
            .description
    )

    @Parameter(
        title: LocalizedStringResource(
            stringLiteral: Localization
                .ItemWidgets
                .Recommendations
                .SelectableTopic
                .parameterName
        )
    )
    var topicEntity: TopicEntity
}

struct TopicEntity: AppEntity {
    typealias DefaultQuery = <#type#>
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Topic"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "cippa")
    }

    var content: TopicContent
    var id: String { "cippa" }
}
