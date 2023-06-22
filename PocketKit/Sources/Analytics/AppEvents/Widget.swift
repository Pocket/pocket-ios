// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public extension Events {
    struct Widget {}
}

public extension Events.Widget {
    struct Tags { }
}

public extension Events.Widget {
    /// Fired when a user taps on a widget and it opens the application
    static func widgetTappedEngagement() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .screen,
                identifier: "widget-extension.tapped"
            )
        )
    }

    /// Fired when a user adds a widget with component details of existing widgets
    static func widgetInstallEngagement(details: [String]) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .screen,
                identifier: "widget-extension.installs",
                componentDetail: String(details.joined(separator: ", ")),
                value: String(details.count)
            )
        )
    }

    /// Fired when a user removes a widget with component details of existing widgets
    static func widgetsRemoveEngagement(details: [String]) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .screen,
                identifier: "widget-extension.uninstalls",
                componentDetail: String(details.joined(separator: ", ")),
                value: String(details.count)
            )
        )
    }
}
