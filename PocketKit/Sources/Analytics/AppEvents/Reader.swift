// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
public extension Events {
    struct Reader {}
}

public extension Events.Reader {
    /**
     Fired when the user views an unsupported content cell in the `Reader`
     */
    static func unsupportedContentViewed(url: URL) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "reader.unsupportedContent"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when the user taps on the button in the unsupported content cell in the `Reader`
     */
    static func unsupportedContentButtonTapped(url: URL) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "reader.unsupportedContent.open"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }
}
