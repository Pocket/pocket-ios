// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol NavigationRoute: Codable, Hashable {}

struct SlateRoute: NavigationRoute {
    let slateID: String
}

struct NativeCollectionRoute: NavigationRoute {
    let slug: String
}

struct SharedWithYouRoute: NavigationRoute {
    let title: String
}

struct WebViewRoute: NavigationRoute {
    let url: URL
    let readerMode: Bool

    init(url: URL, readerMode: Bool = false) {
        self.url = url
        self.readerMode = readerMode
    }
}

struct ReadableRoute: NavigationRoute {
    enum RouteType {
        case syndicated(String)
        case saved(String)
    }

    init(_ type: RouteType) {
        switch type {
        case .syndicated(let itemID):
            self.itemID = itemID
            self.savedItemID = nil
        case .saved(let itemID):
            self.itemID = nil
            self.savedItemID = itemID
        }
    }

    let itemID: String?
    let savedItemID: String?
}
