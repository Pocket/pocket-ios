// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Localization

/// Type containing a named collection of `ItemContent`
public struct ItemContentContainer: Codable, Equatable {
    public let name: String
    public let items: [ItemContent]

    public var isEmpty: Bool {
        self == .empty
    }

    public init(name: String, items: [ItemContent]) {
        self.name = name
        self.items = items
    }

    public static var empty: ItemContentContainer {
        ItemContentContainer(name: "", items: [])
    }
}

/// Type representing the content of a Core Data `Item`.
public struct ItemContent: Codable, Equatable {
    public let url: String
    public let title: String
    public let imageUrl: String?
    public let bestDomain: String
    public let timeToRead: Int?

    public init(url: String,
                title: String,
                imageUrl: String?,
                bestDomain: String,
                timeToRead: Int?) {
        self.url = url
        self.title = title
        self.imageUrl = imageUrl
        self.bestDomain = bestDomain
        self.timeToRead = timeToRead
    }

    /// Human-readable reading time, if `timeToRead` is not nil and greater than zero
    public var readingTime: String? {
            guard let timeToRead,
                  timeToRead > 0 else {
                return nil
            }
            return Localization.minRead(timeToRead)
    }

    /// The URL used to open the saved item within the Pocket reader.
    var pocketURL: URL {
        var components = URLComponents()
        components.scheme = "pocket"
        components.path = "/app/openURL/\(url)"
        components.queryItems = [URLQueryItem(name: "url", value: url)]
        return components.url!
    }
}

extension ItemContent {
    /// Return a placeholder saved item
    public static var placeHolder: ItemContent {
        ItemContent(url: "https://getpocket.com", title: "Pocket Widget", imageUrl: nil, bestDomain: "", timeToRead: nil)
    }

    /// Represents an empty item, used as placeHolder
    public static var empty: ItemContent {
        ItemContent(url: "", title: "", imageUrl: nil, bestDomain: "", timeToRead: nil)
    }
}
