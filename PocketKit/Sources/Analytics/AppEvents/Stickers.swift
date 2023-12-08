// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public extension Events {
    struct Stickers {}
}

public extension Events.Stickers {
    enum MessagesContext: String {
      case media, messages, unknown
    }

    /// Fired when a user opens the sticker drawer
    /// context: should be MSMessagesAppPresentationContext but not binding to that type so
    static func StickersView(context: MessagesContext) -> Impression {
        return Impression(
            component: .screen,
            requirement: .instant,
            uiEntity: UiEntity(
                .screen,
                identifier: "stickers.view",
                componentDetail: context.rawValue
            )
        )
    }
}
