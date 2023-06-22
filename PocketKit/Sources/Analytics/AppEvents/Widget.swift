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
    static func widgetOpenEngagement() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .screen,
                identifier: "widget-extension.tapped"
            )
        )
    }

    /// TODO: not necessarily an engagement event, how should we categorize this
    /// Fired when a user launches the applications and provides details of the widget
    static func widgetDetailsEngagement(details: [String]) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .screen,
                identifier: "widget-extension.details",
                componentDetail: String(details.joined(separator: ", ")),
                value: String(details.count)
            )
        )
    }
}
