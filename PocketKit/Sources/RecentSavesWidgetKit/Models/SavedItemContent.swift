// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// Content of a single saved item
struct SavedItemContent: Identifiable {
    let id = UUID()
    let url: String
    let title: String
    let imageUrl: String?

    /// The URL used to open the saved item within the Pocket reader.
    var pocketURL: URL {
        var components = URLComponents()
        components.scheme = "pocket"
        components.path = "/app/openURL/\(url)"
        components.queryItems = [URLQueryItem(name: "url", value: url)]
        return components.url!
    }
}

extension SavedItemContent {
    /// Return a placeholder saved item
    static var placeHolder: SavedItemContent {
        SavedItemContent(url: "https://getpocket.com", title: "Pocket Widget", imageUrl: nil)
    }
}
