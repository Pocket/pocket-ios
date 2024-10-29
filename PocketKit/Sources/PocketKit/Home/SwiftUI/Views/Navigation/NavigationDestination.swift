// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// Navigation destination from Home
protocol NavigationDestination: Codable, Hashable {}

struct SlateDestination: NavigationDestination {
    let slateID: String
    let slateTitle: String?
}

struct NativeCollectionDestination: NavigationDestination {
    let slug: String
    let givenURL: String
}

struct SharedWithYouDestination: NavigationDestination {
    let title: String
}

struct WebViewDestination: NavigationDestination {
    let url: URL
    let readerMode: Bool

    init(url: URL, readerMode: Bool = false) {
        self.url = url
        self.readerMode = readerMode
    }
}

struct ReadableDestination: NavigationDestination {
    enum RouteType {
        case syndicated(String)
        case saved(String)
    }

    init(_ type: RouteType) {
        switch type {
        case .syndicated(let urlString):
            self.savedItemUrlString = nil
            self.itemUrlString = urlString
        case .saved(let urlString):
            self.itemUrlString = nil
            self.savedItemUrlString = urlString
        }
    }

    let itemUrlString: String?
    let savedItemUrlString: String?
}
