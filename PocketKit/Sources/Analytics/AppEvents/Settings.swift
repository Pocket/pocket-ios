// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
public extension Events {
    struct Settings {}
}

public extension Events.Settings {
    /**
     Fired when a user views the settings screen
     */
    static func SettingsView() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.settings"
            )
        )
    }
}
