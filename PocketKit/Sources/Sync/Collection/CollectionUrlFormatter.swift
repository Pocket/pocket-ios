// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// A formatter for collection URLs
public struct CollectionUrlFormatter {
    static let scheme = "https"
    static let host = "getpocket.com"
    static let collectionComponent = "collection"
    static let collectionComponentIndex = 1
    static let slugComponentIndex = 2
    static let pathComponentsCount = 3

    public init() {}

    public func collectionUrl(_ urlString: String) -> URL? {
        guard let url = URL(string: urlString), url.host == Self.host,
              url.pathComponents.count >= Self.pathComponentsCount,
              url.pathComponents[safe: Self.collectionComponentIndex] == Self.collectionComponent else {
            return nil
        }
        return url
    }

    public func collectionUrlString(_ slug: String) -> String {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host
        return components.url!
            .appendingPathComponent(Self.collectionComponent)
            .appendingPathComponent("\(slug)")
            .absoluteString
    }

    public func isCollectionUrl(_ urlString: String) -> Bool {
        collectionUrl(urlString) != nil
    }

    public func slug(from urlString: String) -> String? {
        guard let url = collectionUrl(urlString) else {
            return nil
        }
        return url.pathComponents[safe: Self.slugComponentIndex]
    }
}
