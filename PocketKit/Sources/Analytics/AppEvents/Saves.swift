// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public extension Events {
    struct Saves { }
}

public extension Events.Saves {
    /// Returns a ContentOpen event for a url that was opened within Saves
    /// - Parameters:
    ///     - destination: Internal, or external, based on whether the content was opened in the reader or web view, respectively
    ///     - trigger: What triggered the content open; defaults to '.click'
    ///     - url: The url of the content that was opened
    static func contentOpen(
        destination: ContentOpen.Destination,
        trigger: ContentOpen.Trigger = .click,
        url: URL
    ) -> ContentOpen {
        return ContentOpen(
            destination: destination,
            trigger: trigger,
            contentEntity: ContentEntity(url: url),
            uiEntity: UiEntity(.card, identifier: "saves.card.open")
        )
    }
}