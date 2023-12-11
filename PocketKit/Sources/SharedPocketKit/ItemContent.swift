// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Localization

/// A Core Data agnostic version of a `Slate`
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

/// A Core Data agnostic version of an `Item`.
public struct ItemContent: Codable {
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

    public var pocketDeeplinkURL: URL {
        var components = URLComponents()
        components.scheme = "pocketWidget"
        components.path = "/itemURL"
        components.queryItems = [URLQueryItem(name: "url", value: url)]
        return components.url!
    }
}

extension ItemContent: Equatable {
    public static func == (lhs: ItemContent, rhs: ItemContent) -> Bool {
        return lhs.url == rhs.url
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
